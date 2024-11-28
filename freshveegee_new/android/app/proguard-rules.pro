# TensorFlow Lite rules
-keep class org.tensorflow.** { *; }
-keepclassmembers class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Flutter rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Prevent stripping for reflection-based code
-keepattributes *Annotation*
-keepclassmembers class ** {
    @androidx.annotation.Keep *;
}

-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication