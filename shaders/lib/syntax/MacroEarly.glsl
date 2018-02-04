/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT
  #define INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT

  #define cv(type) const type
  #define cRCP(type, name) const type name##RCP = 1.0 / name
  #define cin(type) const type

  #define _rgb_to255(x)   ( x * 255.0 )
  #define _rgb_from255(x) (x / 255.0)

#endif /* INTERNAL_INCLUDED_SYNTAX_MACROCONSTANT */
