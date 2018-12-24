// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Lang;

module LangUtils {

  // Deep-copy the given object
  function copy(_oObject) {
    var oCopy = null;
    if(_oObject instanceof Lang.Array) {
      var iSize = _oObject.size();
      oCopy = new [iSize];
      for(var i=0; i<iSize; i++) {
        oCopy[i] = LangUtils.copy(_oObject[i]);
      }
    }
    else if(_oObject instanceof Lang.Dictionary) {
      var amKeys = _oObject.keys();
      var iSize = amKeys.size();
      oCopy = {};
      for(var i=0; i<iSize; i++) {
        var mKey = amKeys[i];
        oCopy.put(mKey, LangUtils.copy(_oObject.get(mKey)));
      }
    }
    else if(_oObject instanceof Lang.Exception) {
      throw new Lang.UnexpectedTypeException();
    }
    else if(_oObject instanceof Lang.Method) {
      throw new Lang.UnexpectedTypeException();
    }
    else {
      oCopy = _oObject;
    }
    return oCopy;
  }

  // Convert a 64-bit (long) integer to byte-array (most significant byte first)
  function ByteArray_fromLong(_l) {
    return [ (_l >> 56).toNumber() & 0xFF,
             (_l >> 48).toNumber() & 0xFF,
             (_l >> 40).toNumber() & 0xFF,
             (_l >> 32).toNumber() & 0xFF,
             (_l >> 24).toNumber() & 0xFF,
             (_l >> 16).toNumber() & 0xFF,
             (_l >> 8).toNumber() & 0xFF,
             _l.toNumber() & 0xFF ]b;
  }
  
  // Convert an hexadecimal-encoded string to byte-array
  function ByteArray_fromHex(_s) {
    // NOTE: Hex = 4-bits/elmt <-> ByteArray = 8-bits/elmt
    //   CB:       16 elmts    (64 bits)       8 elmts
    var ac = _s.toUpper().toCharArray();
    var ba = []b;
    var bits = 0;
    var e = 0;
    var cb = 0l;
    for (var i=0; i<ac.size(); i++) {
      var c = ac[i].toNumber();
      if(c >= 48 and c <= 57) {
        cb = 16*cb + (c - 48);  // Hex: "0" to "9" (=> 0 to 9)
      }
      else if(c >= 65 and c <= 70) {
        cb = 16*cb + (c - 55);  // Hex: "A" to "F" (=> 10 to 15)
      }
      else {
        continue;  // Hex: invalid character
      }
      bits += 4;
      if(e == 15) {  // Hex: 16 elmts (CB)
        ba.addAll(LangUtils.ByteArray_fromLong(cb));  // ByteArray: 8 elmts (CB)
        cb = 0l;
      }
      e = (e + 1) % 16;  // Hex: 16 elmts (CB)
    }
    if(e) {  // pad the missing elements
      for(var i=e; i<16; i++) { cb *= 16; }
      ba.addAll(LangUtils.ByteArray_fromLong(cb));  // ByteArray: 8 elmts (CB)
    }
    return ba.slice(0, bits/8);
  }
  
  // Convert a base32-encoded string to byte-array
  function ByteArray_fromBase32(_s) {
    // NOTE: Base32 = 5-bits/elmt <-> ByteArray = 8-bits/elmt
    //   CB:          8 elmts     (40 bits)       5 elmts
    var ac = _s.toUpper().toCharArray();
    var ba = []b;
    var bits = 0;
    var e = 0;
    var cb = 0l;
    for (var i=0; i<ac.size(); i++) {
      var c = ac[i].toNumber();
      if(c >= 50 and c <= 55) {
        cb = 32*cb + (c - 24);  // Base32: "2" to "7" (=> 26 to 31)
      }
      else if(c >= 65 and c <= 90) {
        cb = 32*cb + (c - 65);  // Base32: "A" to "Z" (=> 0 to 25)
      }
      else {
        continue;  // Base32: invalid character
      }
      bits += 5;
      if(e == 7) {  // Base32: 8 elmts (CB)
        ba.addAll(LangUtils.ByteArray_fromLong(cb).slice(3,8));  // ByteArray: 5 elmts (CB)
        cb = 0l;
      }
      e = (e + 1) % 8;  // Base32: 8 elmts (CB)
    }
    if(e) {  // pad the missing elements
      for(var i=e; i<8; i++) { cb *= 32; }
      ba.addAll(LangUtils.ByteArray_fromLong(cb).slice(3,8));  // ByteArray: 5 elmts (CB)
    }
    return ba.slice(0, bits/8);
  }
  
  // Convert a base64-encoded string to byte-array
  function ByteArray_fromBase64(_s) {
    // NOTE: Base64 = 6-bits/elmt <-> ByteArray = 8-bits/elmt
    //   CB:          8 elmts     (48 bits)       6 elmts
    var ac = _s.toCharArray();
    var ba = []b;
    var bits = 0;
    var e = 0;
    var cb = 0l;
    for (var i=0; i<ac.size(); i++) {
      var c = ac[i].toNumber();
      if(c == 45) {
        cb = 64*cb + 62;  // Base64: "-" (=> 62)
      }
      else if(c == 95) {
        cb = 64*cb + 63;  // Base64: "_" (=> 63)
      }
      else if(c >= 48 and c <= 57) {
        cb = 64*cb + (c + 4);  // Base64: "0" to "9" (=> 52 to 61)
      }
      else if(c >= 65 and c <= 90) {
        cb = 64*cb + (c - 65);  // Base64: "A" to "Z" (=> 0 to 25)
      }
      else if(c >= 97 and c <= 122) {
        cb = 64*cb + (c - 71);  // Base64: "a" to "z" (=> 26 to 51)
      }
      else {
        continue;  // Base64: invalid character
      }
      bits += 6;
      if(e == 7) {  // Base64: 8 elmts (CB)
        ba.addAll(LangUtils.ByteArray_fromLong(cb).slice(2,8));  // ByteArray: 6 elmts (CB)
        cb = 0l;
      }
      e = (e + 1) % 8;  // Base64: 8 elmts (CB)
    }
    if(e) {  // pad the missing elements
      for(var i=e; i<8; i++) { cb *= 64; }
      ba.addAll(LangUtils.ByteArray_fromLong(cb).slice(2,8));  // ByteArray: 6 elmts (CB)
    }
    return ba.slice(0, bits/8);
  }

}
