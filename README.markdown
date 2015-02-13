# Regression Test Selection

This is a demo repository for regression test selection.  You will need Ruby 2.3 to use this (which is currently trunk Ruby).

## Make it go with Minitest

To try it with Minitest, do:

```
$ COLLECTION=1 ruby -I lib spec/whatever_test.rb
```

This will create the initial coverage information.  Then modify `lib/my_thing.rb` so that the diff looks like this:

```patch
diff --git a/lib/my_thing.rb b/lib/my_thing.rb
index 806deff..eb057b9 100644
--- a/lib/my_thing.rb
+++ b/lib/my_thing.rb
@@ -4,7 +4,7 @@ class Whatever
   end
 
   def bar
-    "bar #{@foo}"
+    raise
   end
 
   def baz
```

Now to predict which tests will fail, do this:

```
$ ruby what_to_run.rb
```

## Make it go with RSpec

To try it with RSpec, do:

```
$ COLLECTION=1 rspec spec/whatever_spec.rb
```

This will create the initial coverage information.  Then modify `lib/my_thing.rb` so that the diff looks like this:

```patch
diff --git a/lib/my_thing.rb b/lib/my_thing.rb
index 806deff..eb057b9 100644
--- a/lib/my_thing.rb
+++ b/lib/my_thing.rb
@@ -4,7 +4,7 @@ class Whatever
   end
 
   def bar
-    "bar #{@foo}"
+    raise
   end
 
   def baz
```

Now to predict which tests will fail, do this:

```
$ ruby what_to_run.rb
```
