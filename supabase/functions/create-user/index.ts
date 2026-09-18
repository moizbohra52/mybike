// ============================================================================
// MYBIKE ERP — Supabase Edge Function: create-user
// ============================================================================
// Creates a new auth user + profile + role/showroom assignments.
// Only callable by authenticated users with super_admin or admin role.
// ============================================================================

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CreateUserPayload {
  email: string;
  password: string;
  full_name: string;
  phone?: string;
  role_ids: string[];
  showroom_ids: string[];
  default_showroom_id?: string;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Verify caller authentication
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Create caller client (with user's JWT)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const callerClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user: caller }, error: callerError } = await callerClient.auth.getUser();
    if (callerError || !caller) {
      return new Response(
        JSON.stringify({ error: 'Invalid authentication token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Check caller has admin or super_admin role
    const { data: callerRoles } = await callerClient
      .from('user_roles')
      .select('roles(name)')
      .eq('user_id', caller.id)
      .eq('is_active', true);

    const roleNames = (callerRoles ?? [])
      .map((r: any) => r.roles?.name)
      .filter(Boolean);

    if (!roleNames.includes('super_admin') && !roleNames.includes('admin')) {
      return new Response(
        JSON.stringify({ error: 'Insufficient permissions: Admin role required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 3. Parse and validate payload
    const payload: CreateUserPayload = await req.json();

    if (!payload.email || !payload.password || !payload.full_name) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: email, password, full_name' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (payload.password.length < 6) {
      return new Response(
        JSON.stringify({ error: 'Password must be at least 6 characters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 4. Create auth user using Admin API (service_role)
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);

    const { data: newUser, error: createError } = await adminClient.auth.admin.createUser({
      email: payload.email,
      password: payload.password,
      email_confirm: true,
      user_metadata: {
        full_name: payload.full_name,
      },
    });

    if (createError) {
      return new Response(
        JSON.stringify({ error: `Failed to create user: ${createError.message}` }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const userId = newUser.user.id;

    // 5. Update profile with phone (handle_new_user trigger creates basic profile)
    if (payload.phone) {
      await adminClient
        .from('profiles')
        .update({ phone: payload.phone })
        .eq('id', userId);
    }

    // 6. Assign roles
    if (payload.role_ids && payload.role_ids.length > 0) {
      const roleInserts = payload.role_ids.map((roleId: string) => ({
        user_id: userId,
        role_id: roleId,
        is_active: true,
      }));

      const { error: roleError } = await adminClient
        .from('user_roles')
        .insert(roleInserts);

      if (roleError) {
        console.error('Role assignment error:', roleError);
      }
    }

    // 7. Assign showrooms
    if (payload.showroom_ids && payload.showroom_ids.length > 0) {
      const showroomInserts = payload.showroom_ids.map((showroomId: string) => ({
        user_id: userId,
        showroom_id: showroomId,
        is_default: showroomId === payload.default_showroom_id,
        is_active: true,
      }));

      const { error: showroomError } = await adminClient
        .from('user_showrooms')
        .insert(showroomInserts);

      if (showroomError) {
        console.error('Showroom assignment error:', showroomError);
      }
    }

    // 8. Fetch created user profile for response
    const { data: profile } = await adminClient
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: userId,
          email: payload.email,
          full_name: payload.full_name,
          phone: payload.phone,
          profile,
        },
      }),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Edge Function error:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
