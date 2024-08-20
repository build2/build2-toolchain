**NOTE**: this review is in progress and a comment with the outcome will be added once it's complete.

**NOTE**: the items in this checklist should only be checked off by the person doing the review. The author of the package may indicate the completion of any outstanding items in comments.

- [ ] Repository in the [build2-packaging organization][build2-packaging] if third-party package.
- [ ] Repository/project/package names consistent with upstream, [Debian][debian-pkgs] (see [repository name][rep-name], [package name][pkg-name]).
- [ ] If library without `lib` prefix, no clashes with executable names (see [package name][pkg-name]).
- [ ] Uses git submodule and symlinks for upstream, submodule at correct release commit (see [upstream submodule][upstream-submodule], [upstream symlinks][upstream-symlink]).
- [ ] Follows upstream layout (within reason) (see [package layout][upstream-layout]).
- [ ] [Does not bundle dependencies][dont-bundle-deps].
- [ ] Package archive sizes are not excessive and don't contain unnecessary files.

- [ ] `manifest`: `name`/`project`/`version` values make sense.
- [ ] `manifest`: [`summary`][manifest-summary] value follows guidelines.
- [ ] `manifest`: [`license`][manifest-license] value is SPDX, matches upstream license(s).
- [ ] `manifest`: [`depends`][manifest-depends] values make sense, have corresponding [buildfile imports][manifest-depends-import].

- [ ] `build/bootstrap.build`: makes sense (project name, modules; see [project-wide build system files][build-wide]).
- [ ] `build/root.build`:      makes sense (`cxx.std=latest`).
- [ ] `build/export.build`:    makes sense.

- [ ] Header/Source `buildfile`: [bdep-new generated][use-bdep-new].
- [ ] Header `buildfile`: [overall makes sense][hdr-build].
- [ ] Header `buildfile`: headers installed into library subdirectory or include library name ([background][bad-header-inclusion]).
- [ ] Source `buildfile`: [overall makes sense][src-build].
- [ ] Source `buildfile`: [library is not header-only if upstream supports compiled][header-only].
- [ ] Source `buildfile`: [doesn't use or export undesirable options][compile-options].

- [ ] Root `buildfile`: [overall makes sense][root-build].
- [ ] Root `buildfile`: includes upstream `LICENSE` file (or equivalent).
- [ ] Root `buildfile`: [doesn't build main targets][root-main-targets].

- [ ] Doesn't violate any other [What Not to Do][not-to-do] points without good reason.

- [ ] Above `buildfile` checks applied to tests/examples/etc subprojects/packages.
- [ ] If smoke test, [makes sense][test-smoke] (includes public header, calls non-inline function).

- [ ] `PACKAGE-README.md`: [makes sense][pkg-readme].

- [ ] Above checks applied to all packages.

- [ ] Repository `README.md`: [makes sense][rep-readme].

- [ ] Release is tagged and pushed to `git` repository.

[build2-packaging]: https://github.com/build2-packaging/
[upstream-layout]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-change-upstream
[debian-pkgs]: https://packages.debian.org/
[rep-name]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-repo-name
[pkg-name]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-package-name
[upstream-submodule]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-repo-submodule
[upstream-symlink]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-fill-source
[upstream-layout]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-change-upstream
[dont-bundle-deps]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-bundle

[queue]: https://queue.cppget.org

[not-to-do]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-do

[manifest-license]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-root-manifest-license
[manifest-summary]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-root-manifest-summary
[manifest-depends]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-fill-depend
[manifest-depends-import]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-adjust-build-src-source-dep

[build-wide]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-adjust-build-wide

[use-bdep-new]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-from-scratch
[compile-options]: https://github.com/build2/HOWTO/blob/master/entries/compile-options-in-buildfile.md
[header-only]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-header-only
[bad-header-inclusion]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#howto-bad-inclusion-practice
[hdr-build]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-adjust-build-src-header
[src-build]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-adjust-build-src-source

[root-build]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-root-buildfile
[root-main-targets]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#dont-main-target-root-buildfile

[test-smoke]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-test-smoke-adjust

[pkg-readme]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-root-package-readme
[rep-readme]: https://build2.org/build2-toolchain/doc/build2-toolchain-packaging.xhtml#core-repo-readme
