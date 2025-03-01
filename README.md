EasyCrypt: Computer-Aided Cryptographic Proofs
====================================================================

EasyCrypt is a toolset for reasoning about relational properties of
probabilistic computations with adversarial code. Its main application
is the construction and verification of game-based cryptographic
proofs.

Table of Contents
--------------------------------------------------------------------

 * [EasyCrypt: Computer-Aided Cryptographic Proofs](#easycrypt-computer-aided-cryptographic-proofs)
    - [Installation requirements](#installation-requirements)
    - [Via OPAM](#via-opam)
      - [Installing requirements using OPAM (POSIX systems)](#installing-requirements-using-opam-posix-systems)
      - [Installing requirements using OPAM (non-POSIX systems)](#installing-requirements-using-opam-non-posix-systems)
    - [Via NIX](#via-nix)
 * [Configuring Why3](#configuring-why3)
    - [Note on prover versions](#note-on-prover-versions)
 * [Installing/Compiling EasyCrypt](#installingcompiling-easycrypt)
 * [Proof General Front-End](#proof-general-front-end)
    - [Installing using opam](#installing-using-opam)
    - [Installing from sources](#installing-from-sources)


Installation requirements
--------------------------------------------------------------------

EasyCrypt uses the following third-party tools/libraries:

 * OCaml (>= 4.08)

     Available at https://ocaml.org/

 * OCamlbuild

 * Why3 (>= 1.7.x, < 1.8)

     Available at <http://why3.lri.fr/>

     Why3 must be installed with a set a provers.
     See <http://why3.lri.fr/#provers>

     Why3 libraries must be installed (make byte && make install-lib)

 * Menhir <http://gallium.inria.fr/~fpottier/menhir/>

 * OCaml Batteries Included <http://batteries.forge.ocamlcore.org/>

 * OCaml PCRE (>= 7) <https://github.com/mmottl/pcre-ocaml>

 * OCaml Zarith <https://forge.ocamlcore.org/projects/zarith>

 * OCaml ini-files <http://archive.ubuntu.com/ubuntu/pool/universe/o/ocaml-inifiles/>

On POSIX/Win32 systems (GNU/Linux, *BSD, OS-X), we recommend that users
install EasyCrypt and all its dependencies via `opam`.

Via OPAM
--------------------------------------------------------------------

### Installing requirements using OPAM 2 (POSIX systems)

Opam can be easily installed from source or via your packages manager:

  * On Ubuntu and derivatives:

      ```
      $> add-apt-repository ppa:avsm/ppa
      $> apt-get update
      $> apt-get install ocaml ocaml-native-compilers camlp4-extra opam
      ```

  * On Fedora/OpenSUSE:

      ```
      $> sudo dnf update
      $> sudo dnf install ocaml ocaml-docs ocaml-camlp4-devel opam
      ```

  * On MacOSX using brew:

      ```
      $> brew install ocaml opam
      ```

Once `opam` and `ocaml` has been successfully installed run the following:

```
$> opam init
$> eval $(opam env)
```

For any issues encountered installing `opam` see:

  * [https://opam.ocaml.org/doc/Install.html] for detailed opam installation instructions.

  * [https://opam.ocaml.org/doc/Usage.html] for how to initialize opam.

You can then install all the needed dependencies via the opam OCaml
packages manager.

  0. Optionally, switch to a dedicated compiler for EasyCrypt:

      ```
      $> opam switch create easycrypt $OVERSION
      ```

      where `$OVERSION` is a valid OCaml version (e.g. ocaml-base-compiler.4.07.0)

  1. Add the EasyCrypt package from repository:

      ```
      $> opam pin -yn add easycrypt https://github.com/EasyCrypt/easycrypt.git
      ```

  2. Optionally, use opam to install the system dependencies:

      ```
      $> opam install opam-depext
      $> opam depext easycrypt
      ```

  3. Install EasyCrypt's dependencies:

      ```
      $> opam install --deps-only easycrypt
      $> opam install alt-ergo
      ```

     If you get errors about ocamlbuild failing because it's already
     installed, the check can be skipped with the following:

      ```
      CHECK_IF_PREINSTALLED=false opam install --deps-only easycrypt
      ```

  4. You can download extra provers at the following URLs:

     * Z3: [https://github.com/Z3Prover/z3]
     * CVC4: [https://cvc4.github.io/]

### Installing requirements using OPAM (non-POSIX systems)

You can install all the needed dependencies via the opam OCaml packages manager.

  1. Install the opam Ocaml packages manager, following the instructions at:

     https://fdopen.github.io/opam-repository-mingw/installation/

  2. Add the EasyCrypt package from repository:

      ```
      $> opam pin -yn add easycrypt https://github.com/EasyCrypt/easycrypt.git
      ```

  3. Use opam to install the system dependencies:

      ```
      $> opam install depext depext-cygwinports
      $> opam depext easycrypt
      ```

  4. Install EasyCrypt's dependencies:

      ```
      $> opam install --deps-only easycrypt
      $> opam install alt-ergo
      ```

  5. You can download extra provers at the following URLs:

     * Z3: [https://github.com/Z3Prover/z3]
     * CVC4: [https://cvc4.github.io/]


Via NIX
--------------------------------------------------------------------

First, install the [Nix package manager](https://nixos.org/) by
following [these instructions](https://nixos.org/manual/nix/stable/#chap-installation).

Then, at the root of the EasyCrypt source tree, type:

    ```
    $> nix-shell
    ```
    
These should install all the required dependencies. From there, simply
run:

    ```
    $> make
    ```
    
to compile EasyCrypt.

Note on Prover Versions
--------------------------------------------------------------------

Why3 and SMT solvers are independent pieces of software with their
own version-specific interactions. Obtaining a working SMT setup may
require installing specific versions of some of the provers.

At the time of writing, we depend on Why3 1.7.x, which supports the
following prover versions:

 * Alt-Ergo 2.5.2
 * CVC4 1.8
 * CVC5 1.0.8
 * Z3 4.12.x

`alt-ergo` can be installed using opam, if you do you can use pins to
select a specific version (e.g, `opam pin alt-ergo 2.5.2`).

Installing/Compiling EasyCrypt
====================================================================

If installing from source, running

```
$> make
$> make install
```

builds and install EasyCrypt (under the binary named `easycrypt`),
assuming that all dependencies have been successfully installed. If
you choose not to install EasyCrypt system wide, you can use the
binary `ec.native` that is located at the root of the source tree.

EasyCrypt comes also with an opam package. Running

```
$> opam install easycrypt
```

installs EasyCrypt and its dependencies via opam. In that case, the
EasyCrypt binary is named `easycrypt`.

Configuring Why3
====================================================================

Initially, and after the installation/removal/update of SMT provers,
you need to (re)configure Why3 via the following `easycrypt` command:

```
$> easycrypt why3config
```

EasyCrypt stores the Why3 configuration file under

```
$XDG_CONFIG_HOME/easycrypt/why3.conf
```

EasyCrypt allows you, via the option -why3, to load a Why3
configuration file from a custom location. For instance:

```
$> easycrypt why3config -why3 $WHY3CONF.conf
$> easycrypt -why3 $WHY3CONF.conf
```

where `$WHY3CONF` must be replaced by some custom location.

Proof General Front-End
====================================================================

EasyCrypt mode has been integrated upstream. Please, go
to <https://github.com/ProofGeneral/PG> and follow the instructions.

Examples
====================================================================

Examples of how to use EasyCrypt are in the `examples` directory. You
will find basic examples at the root of this directory, as well as a
more advanced example in the `MEE-CBC` sub-directory and a tutorial on
how to use the complexity system in `cost` sub-directory.
