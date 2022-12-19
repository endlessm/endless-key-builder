Endless Key Builder (EKB)
=========================

This program assembles an archive file that can be used to create physical
Endless Key devices, by downloading the necessary programs and content.

Design
======

The core is written in bash and has just enough flexibility to our needs. The
simplicity allows us to have a complete in-house understanding of the build
system, enabling smooth organic growth as our requirements evolve.

The top level entry point is written in python. This is done to provide
a rich configuration environment that allows Endless to quickly adjust
to different product needs. See the [Configuration](#Configuration)
section below for a detailed description of the builder configuration.

When added complexity is minimal, we prefer calling into lower level tools
directly rather than utilizing abstraction layers. This helps keep the builder
code simple and legible.

The build process is divided into a few stages, as detailed below.

content stage
-------------

This stage pulls or generates the necessary programs and extra files (ex., the
"Getting Started" PDF).

kolibri stage
-------------

This stage generates the configuration for Kolibri and pulls all Kolibri
content included in the build.

archive stage
-------------

This stage generates the final archive file and its corresponding checksum.

Setup
=====

Known to work on Debian Buster (10) and newer. Required packages:

 * coreutils
 * curl
 * jq
 * python3
 * python3-venv
 * unzip
 * zip

Configuration
=============

The build configuration is built up from a series of INI files, which are
stored in the `config` directory of the builder. The order of configuration
files read in is:

 * Default settings - `config/defaults.ini`
 * Codename settings - `config/codename/$codename.ini`
 * Host settings - `${sysconfdir}/config.ini`, where `${sysconfdir}` defaults
   to `/etc/endless-key-builder`.
 * User settings - `${userconfdir}/config.ini`, where `${userconfdir}` defaults
   to `~/.config/endless-key-builder`

The host and user configuration files are not typically used. They can allow
for a permanent or temporary override for a particular host or user.

Finally, there are extra configuration files whose settings will be used during
the build but not displayed in the saved configuration file:

 * Host private settings - `${sysconfdir}/private.ini`, where `${sysconfdir}`
   defaults to `/etc/endless-key-builder`.
 * User private settings - `${userconfdir}/private.ini`, where
   `${userconfdir}` defaults to `/etc/endless-key-builder`.

None of these files are required to be present, all required settings have
hard-coded defaults in case no configuration is present.

The supplied `defaults.ini` file contains an explanation and default value for
each possible setting that can be used for the build, and new settings should
be added and documented there.

Format
------

The format of the configuration files is INI as mentioned above.
However, a form of interpolation is used to allow referring to other
options. For instance, an option `foo` can use the value from an option
`bar` by using `${bar}` in its value. If `bar` was in a different
section, it can be referred to by prepending the other section in the
form of `${other:bar}`.

The INI file parsing is done using the `configparser` `python` module.
The interpolation feature is provided by its `ExtendedInterpolation`
class. See the `python`
[documentation](https://docs.python.org/3/library/configparser.html#configparser.ExtendedInterpolation)
for a more detailed discussion of this feature.

Accessing options
-----------------

The build core accesses these settings via environment variables. The
variables take the form of `EKB_$SECTION_$OPTION`. The `build` section
is special and these settings are exported in the form `EKB_$OPTION`
without the section in the variable name.

Seeing the full configuration
-----------------------------

In order to see the full configuration after merging all configuration files,
pass the `--debug` option on the command line. This will print the merged
configuration in INI format. The merged configuration is also saved during the
build into the output directory.

If you want to see the full configuration without building any artifacts or
downloading anything, add the `--dry-run` option to the command line as well.

Execution
=========

To build your own Endless Key archive file, pass the codename of the
configuration you want to build to the `endless-key-builder` program:

```
./endless-key-builder [options] CODENAME
```

Optional arguments (most users will not need any of them):
 * `--help`, `-h`: show help message and exit
 * `--debug`: enable debug output
 * `--dry-run`: do not download or build anything
 * `--project-prefix PROJECT_PREFIX`: set the prefix to be used for the kolibri
   PROJECT setting (default: ekbcustom)


The build artifacts will be generated in the `build/` directory, unless changed
by the configuration, with the archive, checksum and config being located inside
`build/out/`.

Running containerized
---------------------

This program can be easily run inside a container using the accompanying
`Dockerfile.build` file, which defines a container based on a very small
Endless OS container image, adding all the required dependencies. Below are
some examples of how to run it in a container.

Please note that this does not aim to cover all possible ways to run it using a
certain container technology, or all container technologies that could be used
for that; it just aims to be a reference with some commands we tried and had
success with. Before trying any of the commands below, make sure you understand
what they do and that you are familiar with the container technology being
used. Also, after running some of the commands in this section, some container
images may be left taking up space in your system, so you may want to remove
them once you know you won't use them anymore.

### Docker
You may want to replace `$UID`, `$GROUPS` and `$HOME`, and adjust bind-mounts
accordingly.
```
sudo docker build -t endless-key-builder -f Dockerfile.build .
sudo docker run --read-only --rm --tty --user=$UID:$GROUPS \
  --volume=$HOME/src/endless-key-builder:/home/endless-key-builder:rw \
  --workdir=/home/endless-key-builder \
  endless-key-builder ./endless-key-builder 1GB
```
