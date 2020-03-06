AC_INIT([edflib], [1.1.0], [sio@tesser.org])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([subdir-objects])
LT_INIT

AC_PROG_AWK
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_INSTALL
AC_PROG_LN_S

AC_CHECK_HEADERS([stdint.h stdlib.h string.h syslog.h unistd.h])

AC_TYPE_SIZE_T
AC_TYPE_UINT64_T

AC_CHECK_FUNCS([strerror])

AC_CONFIG_HEADERS([config.h])
AC_CHECK_HEADERS([stdlib.h string.h syslog.h])
AC_CONFIG_FILES([
 Makefile
])
AC_OUTPUT
