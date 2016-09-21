NodeJam Spec
===

Init Command
---
Initializes a directory.
The directory is immediately buildable with ```nodejam build```.
```
# Initialize the directory with the default template.
nodejam init

#Initialize the directory with the template <template-name>.
nodejam init <template-name>
```

Build Command
---
Build the project.

```
# Generate into \_site.
nodejam build

# Generate from <source> to <destination>
# If omitted, default source is current directory and default destination is _site.
nodejam build --source <source> --destination <destination>
```
