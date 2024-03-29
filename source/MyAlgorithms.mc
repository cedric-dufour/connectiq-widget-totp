// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// TOTP (Garmin ConnectIQ) Widget (TOTP)
// Copyright (C) 2018-2022 Cedric Dufour <http://cedric.dufour.name>
//
// TOTP (Garmin ConnectIQ) Widget (TOTP) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// TOTP (Garmin ConnectIQ) Widget (TOTP) is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Cryptography as Crypto;
using Toybox.Math;
using Toybox.System as Sys;

// REFERENCES:
//   TOTP:  https://tools.ietf.org/html/rfc6238
//   HOTP:  https://tools.ietf.org/html/rfc4226
//   HMAC:  https://tools.ietf.org/html/rfc2104
//   SHA:   https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf

// NOTES:
//   TOTP may use any SHA variant (RFC6238, §1.2)
//   TOTP should allow any T0 and TX (RFC6238, §4.2)
//   TOTP must support 64-bit timestamps (RFC6238, §4.2)

//
// MODULE
//

(:glance)
module MyAlgorithms {

  //
  // CONSTANTS
  //

  // HMAC
  const HMAC_BLOCKSIZE = 64;  // (RFC2104, §2, "B=64 for all [...]")
  const HMAC_IPAD = 0x36;
  const HMAC_OPAD = 0x5C;

  // Encoding
  const ENCODING_HEX = 0;
  const ENCODING_BASE32 = 1;
  const ENCODING_BASE64 = 2;


  //
  // FUNCTIONS: self
  //

  function HMAC(_baK as ByteArray, _baM as ByteArray, _iH as Number) as ByteArray {
    // (RFC2104, §2 and §3)

    // HMAC
    try {
      // Natively-supported
      var oHMAC = new Crypto.HashBasedMessageAuthenticationCode({:algorithm => _iH as Crypto.HashAlgorithm, :key => _baK});
      oHMAC.update(_baM);
      return oHMAC.digest();
    }
    catch(e) {
      // F***! We must do our own implementation (Why, Garmin? Why?!?)
      var oHASH;

      // ... key size
      if(_baK.size() > HMAC_BLOCKSIZE) {
        oHASH = new Crypto.Hash({:algorithm => _iH as Crypto.HashAlgorithm});
        oHASH.update(_baK);
        _baK = oHASH.digest();
      }

      // ... step (1) and (2)
      var baIPad = new [HMAC_BLOCKSIZE]b;
      for (var i=0; i<_baK.size(); i++) {
        baIPad[i] = _baK[i] ^ HMAC_IPAD;  // Ki XOR ipad
      }
      for (var i=_baK.size(); i<HMAC_BLOCKSIZE; i++) {
        baIPad[i] = HMAC_IPAD;  // 0 XOR ipad
      }

      // ... step (3)
      baIPad.addAll(_baM);

      // ... step (4)
      oHASH = new Crypto.Hash({:algorithm => _iH as Crypto.HashAlgorithm});
      oHASH.update(baIPad);
      baIPad = oHASH.digest();

      // ... step (1) and (5)
      var baOPad = new [HMAC_BLOCKSIZE]b;
      for (var i=0; i<_baK.size(); i++) {
        baOPad[i] = _baK[i] ^ HMAC_OPAD;  // Ki XOR opad
      }
      for (var i=_baK.size(); i<HMAC_BLOCKSIZE; i++) {
        baOPad[i] = HMAC_OPAD;  // 0 XOR opad
      }

      // ... step (6)
      baOPad.addAll(baIPad);

      // ... step (7)
      oHASH = new Crypto.Hash({:algorithm => _iH as Crypto.HashAlgorithm});
      oHASH.update(baOPad);
      return oHASH.digest();
    }
  }

  function HOTP_Code(_iD as Number, _baK as ByteArray, _baC as ByteArray, _iH as Number) as String {
    // (RFC4226, §5.3)

    // HMAC
    var baHMAC = MyAlgorithms.HMAC(_baK, _baC, _iH);

    // Dynamic Truncation

    // ... last 4 bits => offset ({0..15})
    var iOffset = baHMAC[baHMAC.size()-1] & 0x0F;

    // ... 4 bytes, starting at offset, without MSB => 31-bit binary code
    var iBinaryCode =
      (baHMAC[iOffset] & 0x7F) << 24
      | baHMAC[iOffset+1] << 16
      | baHMAC[iOffset+2] << 8
      | baHMAC[iOffset+3];

    // Code

    // ... last D digits => HTOP code
    var sCode = (iBinaryCode as Number).format("%010d");
    return sCode.substring(sCode.length()-_iD, sCode.length());
  }

  function TOTP_Counter(_lT as Long, _lT0 as Long, _iTX as Number) as Array {
    // (RFC6238, §4.2)

    // Counter

    // ... as 64-bit (long) integer
    var lTc = ( (_lT - _lT0) / _iTX ).toLong();

    // ... as 8-byte array
    var baTc = LangUtils.ByteArray_fromLong(lTc);

    // ... remainder
    var iTr = ( _iTX - (_lT - _lT0) % _iTX ).toNumber();

    // Return all components
    return [baTc, lTc, iTr];
  }

  function TOTP_Code(_iD as Number, _baK as ByteArray, _lT as Long, _lT0 as Long, _iTX as Number, _iH as Number) as String {
    // Code (HOTP with C=Tc)
    return HOTP_Code(_iD, _baK, MyAlgorithms.TOTP_Counter(_lT, _lT0, _iTX)[0] as ByteArray, _iH);
  }

  function ByteArray_fromEncoding(_s as String, _iE as Number) as ByteArray {
    if(_iE == MyAlgorithms.ENCODING_HEX) {
      return LangUtils.ByteArray_fromHex(_s);
    }
    else if(_iE == MyAlgorithms.ENCODING_BASE32) {
      return LangUtils.ByteArray_fromBase32(_s);
    }
    else if(_iE == MyAlgorithms.ENCODING_BASE64) {
      return LangUtils.ByteArray_fromBase64(_s);
    }
    return []b;  // WTF!?!
  }

}
