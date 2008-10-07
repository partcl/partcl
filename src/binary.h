/*
 * $Id: binary.h 21247 2007-09-13 06:31:01Z paultcochrane $
 * Copyright (C) 2007, The Perl Foundation.
 */

#ifndef PARROT_TCL_BINARY_H_GUARD
#define PARROT_TCL_BINARY_H_GUARD

PMC *ParTcl_binary_scan(PARROT_INTERP, STRING *BINSTR, STRING *FORMAT);
STRING *ParTcl_binary_format(PARROT_INTERP, STRING *FORMAT, PMC *values);

#endif /* PARROT_TCL_BINARY_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
