# build2-toolchain - build2 toolchain amalgamation

`build2` is an open source (MIT), cross-platform build toolchain that provides
sufficient depth and flexibility to develop and package complex C/C++
projects. The toolchain is a hierarchy of tools consisting of a
general-purpose build system, package manager (for package consumption), and
project manager (for project development).

For more information refer to the [`build2` home page](https://build2.org) and
the [`build2` project organization](https://github.com/build2/) on GitHub.

This package contains the `build2` toolchain amalgamation that bundles (as
`git` submodules) the build system (`build2`), the package manager (`bpkg`),
the project manager (`bdep`), and the standard pre-installed build system
modules (`libbuild2-*`), as well as a few `build2` libraries that they
require.

This `README` file contains information that is more appropriate for
development or packaging of the toolchain. If you simply want to install and
use it, then rather refer to the [installation
instructions](https://build2.org/install.xhtml). Note also that the packaged
[development snapshots](https://build2.org/community.xhtml#stage) are
available as well.

Note that the primary purpose of this amalgamation is consumption rather than
development. In particular, it is the standard way to build and install the
toolchain [from source](https://build2.org/install-src.xhtml) as well as to
build its binary packages.

## Packaging

If you wish to package the toolchain (for example, for a Linux distribution),
then the recommended starting point is the [Toolchain Installation and
Upgrade](https://build2.org/build2-toolchain/doc/build2-toolchain-install.xhtml)
documentation. It is also available in the accompanying `INSTALL` file.

## Development

Setting up the environment to develop the `build2` toolchain itself is
somewhat complicated because we use it for its own development and that often
poses chicken-and-egg kinds of problems. For details see the [_How do I setup
the build2 toolchain for
development?_](https://github.com/build2/HOWTO/blob/master/entries/setup-build2-for-development.md)
HOWTO article.
