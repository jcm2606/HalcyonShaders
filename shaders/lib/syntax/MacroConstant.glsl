/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT
  #define INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT

  #define cv(type) const type
  #define cRCP(type, name) const type name##RCP = 1.0 / name
  #define cin(type) const in type

#endif /* INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT */
