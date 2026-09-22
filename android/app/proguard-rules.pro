# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase & GoTrue / Postgrest / Realtime JSON serialization
-keepattributes *Annotation*,EnclosingMethod,InnerClasses,Signature
-keepclassmembers enum * { *; }
-dontwarn javax.annotation.**
-dontwarn kotlin.reflect.**
-dontwarn org.bouncycastle.**

# AndroidX & Security
-keep class androidx.security.crypto.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.window.** { *; }

# Printing & PDF rendering
-dontwarn net.sf.image4j.**
