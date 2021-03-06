# multiarch.m4 serial 3
dnl Copyright (C) 2008 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

# Determine whether the compiler is or may be producing universal binaries.
#
# On MacOS X 10.5 and later systems, the user can create libraries and
# executables that work on multiple system types--known as "fat" or
# "universal" binaries--by specifying multiple '-arch' options to the
# compiler but only a single '-arch' option to the preprocessor.  Like
# this:
#
#     ./configure CC="gcc -arch i386 -arch x86_64 -arch ppc -arch ppc64" \
#                 CXX="g++ -arch i386 -arch x86_64 -arch ppc -arch ppc64" \
#                 CPP="gcc -E" CXXCPP="g++ -E"
#
# Detect this situation and set the macro AA_APPLE_UNIVERSAL_BUILD at the
# beginning of config.h and set APPLE_UNIVERSAL_BUILD accordingly.

AC_DEFUN([gl_MULTIARCH],
[
  dnl This AC_REQUIRE is not necessary in theory. It works around a bug in
  dnl autoconf <= 2.63: AC_REQUIRE invocations inside AC_REQUIREd macros are
  dnl being handled better than AC_REQUIRE invocations inside normally invoked
  dnl macros.
  AC_REQUIRE([gl_MULTIARCH_BODY])
])

AC_DEFUN([gl_MULTIARCH_BODY],
[
  dnl Code similar to autoconf-2.63 AC_C_BIGENDIAN.
  gl_cv_c_multiarch=no
  AC_COMPILE_IFELSE(
    [AC_LANG_SOURCE(
      [[#ifndef __APPLE_CC__
         not a universal capable compiler
        #endif
        typedef int dummy;
      ]])],
    [
     dnl Check for potential -arch flags.  It is not universal unless
     dnl there are at least two -arch flags with different values.
     arch=
     prev=
     for word in ${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}; do
       if test -n "$prev"; then
         case $word in
           i?86 | x86_64 | ppc | ppc64)
             if test -z "$arch" || test "$arch" = "$word"; then
               arch="$word"
             else
               gl_cv_c_multiarch=yes
             fi
             ;;
         esac
         prev=
       else
         if test "x$word" = "x-arch"; then
           prev=arch
         fi
       fi
     done
    ])
  if test $gl_cv_c_multiarch = yes; then
    AC_DEFINE([AA_APPLE_UNIVERSAL_BUILD], [1],
      [Define if the compiler is building for multiple architectures of Apple platforms at once.])
    APPLE_UNIVERSAL_BUILD=1
  else
    APPLE_UNIVERSAL_BUILD=0
  fi
  AC_SUBST([APPLE_UNIVERSAL_BUILD])
])
