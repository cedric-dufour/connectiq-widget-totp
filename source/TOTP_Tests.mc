// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// TOTP (Garmin ConnectIQ) Widget (TOTP)
// Copyright (C) 2018 Cedric Dufour <http://cedric.dufour.name>
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

using Toybox.Cryptography as Crypto;
using Toybox.Lang;

// REFERENCES:
//   https://tools.ietf.org/html/rfc2202
//   https://tools.ietf.org/html/rfc4231

(:test)
module TOTP_Tests {

  const STRING_TESTCASE = "Test case";
  const STRING_PASS = "PASS";
  const STRING_FAIL = "FAIL";

  (:test)
    function unitTest_RFC2202_MD5(_oLogger) {
    var iError = 0;
    var iTest;
    var baK;
    var baM;
    var baD;

    // MD5: Test case 1
    iTest = 1;
    baK = new [16]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0B; }
    baM = []b.addAll("Hi There".toCharArray());
    baD = [0x92, 0x94, 0x72, 0x7A, 0x36, 0x38, 0xBB, 0x1C, 0x13, 0xF4, 0x8E, 0xF8, 0x15, 0x8B, 0xFC, 0x9D]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 2
    iTest = 2;
    baK = []b.addAll("Jefe".toCharArray());
    baM = []b.addAll("what do ya want for nothing?".toCharArray());
    baD = [0x75, 0x0C, 0x78, 0x3E, 0x6A, 0xB0, 0xB5, 0x03, 0xEA, 0xA8, 0x6E, 0x31, 0x0A, 0x5D, 0xB7, 0x38]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 3
    iTest = 3;
    baK = new [16]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xDD; }
    baD = [0x56, 0xBE, 0x34, 0x52, 0x1D, 0x14, 0x4C, 0x88, 0xDB, 0xB8, 0xC7, 0x33, 0xF0, 0xE8, 0xB3, 0xF6]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 4
    iTest = 4;
    baK = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19]b;
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xCD; }
    baD = [0x69, 0x7E, 0xAF, 0x0A, 0xCA, 0x3A, 0x3A, 0xEA, 0x3A, 0x75, 0x16, 0x47, 0x46, 0xFF, 0xAA, 0x79]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 5
    iTest = 5;
    baK = new [16]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0C; }
    baM = []b.addAll("Test With Truncation".toCharArray());
    baD = [0x56, 0x46, 0x1E, 0xF2, 0x34, 0x2E, 0xDC, 0x00, 0xF9, 0xBA, 0xB9, 0x95, 0x69, 0x0E, 0xFD, 0x4C]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 6
    iTest = 6;
    baK = new [80]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("Test Using Larger Than Block-Size Key - Hash Key First".toCharArray());
    baD = [0x6B, 0x1A, 0xB7, 0xFE, 0x4B, 0xD7, 0xBF, 0x8F, 0x0B, 0x62, 0xE6, 0xCE, 0x61, 0xB9, 0xD0, 0xCD]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // MD5: Test case 7
    iTest = 7;
    baK = new [80]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data".toCharArray());
    baD = [0x6F, 0x63, 0x0F, 0xAD, 0x67, 0xCD, 0xA0, 0xEE, 0x1F, 0xB1, 0xF5, 0x62, 0xDB, 0x3A, 0xA5, 0x3E]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_MD5))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_RFC2202_SHA1(_oLogger) {
    var iError = 0;
    var iTest;
    var baK;
    var baM;
    var baD;

    // SHA1: Test case 1
    iTest = 1;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0B; }
    baM = []b.addAll("Hi There".toCharArray());
    baD = [0xB6, 0x17, 0x31, 0x86, 0x55, 0x05, 0x72, 0x64, 0xE2, 0x8B, 0xC0, 0xB6, 0xFB, 0x37, 0x8C, 0x8E, 0xF1, 0x46, 0xBE, 0x00]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 2
    iTest = 2;
    baK = []b.addAll("Jefe".toCharArray());
    baM = []b.addAll("what do ya want for nothing?".toCharArray());
    baD = [0xEF, 0xFC, 0xDF, 0x6A, 0xE5, 0xEB, 0x2F, 0xA2, 0xD2, 0x74, 0x16, 0xD5, 0xF1, 0x84, 0xDF, 0x9C, 0x25, 0x9A, 0x7C, 0x79]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 3
    iTest = 3;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xDD; }
    baD = [0x12, 0x5D, 0x73, 0x42, 0xB9, 0xAC, 0x11, 0xCD, 0x91, 0xA3, 0x9A, 0xF4, 0x8A, 0xA1, 0x7B, 0x4F, 0x63, 0xF1, 0x75, 0xD3]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 4
    iTest = 4;
    baK = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19]b;
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xCD; }
    baD = [0x4C, 0x90, 0x07, 0xF4, 0x02, 0x62, 0x50, 0xC6, 0xBC, 0x84, 0x14, 0xF9, 0xBF, 0x50, 0xC8, 0x6C, 0x2D, 0x72, 0x35, 0xDA]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 5
    iTest = 5;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0C; }
    baM = []b.addAll("Test With Truncation".toCharArray());
    baD = [0x4C, 0x1A, 0x03, 0x42, 0x4B, 0x55, 0xE0, 0x7F, 0xE7, 0xF2, 0x7B, 0xE1, 0xD5, 0x8B, 0xB9, 0x32, 0x4A, 0x9A, 0x5A, 0x04]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 6
    iTest = 6;
    baK = new [80]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("Test Using Larger Than Block-Size Key - Hash Key First".toCharArray());
    baD = [0xAA, 0x4A, 0xE5, 0xE1, 0x52, 0x72, 0xD0, 0x0E, 0x95, 0x70, 0x56, 0x37, 0xCE, 0x8A, 0x3B, 0x55, 0xED, 0x40, 0x21, 0x12]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case 7
    iTest = 7;
    baK = new [80]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data".toCharArray());
    baD = [0xE8, 0xE9, 0x9D, 0x0F, 0x45, 0x23, 0x7D, 0x78, 0x6D, 0x6B, 0xBA, 0xA7, 0x96, 0x5C, 0x78, 0x08, 0xBB, 0xFF, 0x1A, 0x91]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_RFC4231_SHA256(_oLogger) {
    var iError = 0;
    var iTest;
    var baK;
    var baM;
    var baD;

    // SHA256: Test case 1
    iTest = 1;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0B; }
    baM = []b.addAll("Hi There".toCharArray());
    baD = [0xB0, 0x34, 0x4C, 0x61, 0xD8, 0xDB, 0x38, 0x53, 0x5C, 0xA8, 0xAF, 0xCE, 0xAF, 0x0B, 0xF1, 0x2B, 0x88, 0x1D, 0xC2, 0x00, 0xC9, 0x83, 0x3D, 0xA7, 0x26, 0xE9, 0x37, 0x6C, 0x2E, 0x32, 0xCF, 0xF7]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 2
    iTest = 2;
    baK = []b.addAll("Jefe".toCharArray());
    baM = []b.addAll("what do ya want for nothing?".toCharArray());
    baD = [0x5B, 0xDC, 0xC1, 0x46, 0xBF, 0x60, 0x75, 0x4E, 0x6A, 0x04, 0x24, 0x26, 0x08, 0x95, 0x75, 0xC7, 0x5A, 0x00, 0x3F, 0x08, 0x9D, 0x27, 0x39, 0x83, 0x9D, 0xEC, 0x58, 0xB9, 0x64, 0xEC, 0x38, 0x43]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 3
    iTest = 3;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xDD; }
    baD = [0x77, 0x3E, 0xA9, 0x1E, 0x36, 0x80, 0x0E, 0x46, 0x85, 0x4D, 0xB8, 0xEB, 0xD0, 0x91, 0x81, 0xA7, 0x29, 0x59, 0x09, 0x8B, 0x3E, 0xF8, 0xC1, 0x22, 0xD9, 0x63, 0x55, 0x14, 0xCE, 0xD5, 0x65, 0xFE]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 4
    iTest = 4;
    baK = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19]b;
    baM = new [50]b; for (var i=0; i<baM.size(); i++) { baM[i] = 0xCD; }
    baD = [0x82, 0x55, 0x8A, 0x38, 0x9A, 0x44, 0x3C, 0x0E, 0xA4, 0xCC, 0x81, 0x98, 0x99, 0xF2, 0x08, 0x3A, 0x85, 0xF0, 0xFA, 0xA3, 0xE5, 0x78, 0xF8, 0x07, 0x7A, 0x2E, 0x3F, 0xF4, 0x67, 0x29, 0x66, 0x5B]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 5
    iTest = 5;
    baK = new [20]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0x0C; }
    baM = []b.addAll("Test With Truncation".toCharArray());
    baD = [0xA3, 0xB6, 0x16, 0x74, 0x73, 0x10, 0x0E, 0xE0, 0x6E, 0x0C, 0x79, 0x6C, 0x29, 0x55, 0x55, 0x2B]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256).slice(0,16))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 6
    iTest = 6;
    baK = new [131]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("Test Using Larger Than Block-Size Key - Hash Key First".toCharArray());
    baD = [0x60, 0xE4, 0x31, 0x59, 0x1E, 0xE0, 0xB6, 0x7F, 0x0D, 0x8A, 0x26, 0xAA, 0xCB, 0xF5, 0xB7, 0x7F, 0x8E, 0x0B, 0xC6, 0x21, 0x37, 0x28, 0xC5, 0x14, 0x05, 0x46, 0x04, 0x0F, 0x0E, 0xE3, 0x7F, 0x54]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case 7
    iTest = 7;
    baK = new [131]b; for (var i=0; i<baK.size(); i++) { baK[i] = 0xAA; }
    baM = []b.addAll("This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm.".toCharArray());
    baD = [0x9B, 0x09, 0xFF, 0xA7, 0x1B, 0x94, 0x2F, 0xCB, 0x27, 0x63, 0x5F, 0xBC, 0xD5, 0xB0, 0xE9, 0x44, 0xBF, 0xDC, 0x63, 0x64, 0x4F, 0x07, 0x13, 0x93, 0x8A, 0x7F, 0x51, 0x53, 0x5C, 0x3A, 0x35, 0xE2]b;
    if(baD.equals(TOTP_Algorithms.HMAC(baK, baM, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_RFC6238_SHA1(_oLogger) {
    var iError = 0;
    var lT;
    var baK = [0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30]b;
    var sTOTP;

    // SHA1: Test case T=59
    lT = 59l;
    sTOTP = "94287082";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case T=1111111109
    lT = 1111111109l;
    sTOTP = "07081804";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case T=1111111111
    lT = 1111111111l;
    sTOTP = "14050471";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case T=1234567890
    lT = 1234567890l;
    sTOTP = "89005924";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case T=2000000000
    lT = 2000000000l;
    sTOTP = "69279037";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA1: Test case T=20000000000
    lT = 20000000000l;
    sTOTP = "65353130";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA1))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_RFC6238_SHA256(_oLogger) {
    var iError = 0;
    var lT;
    var baK = [0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32]b;
    var sTOTP;

    // SHA256: Test case T=59
    lT = 59l;
    sTOTP = "46119246";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case T=1111111109
    lT = 1111111109l;
    sTOTP = "68084774";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case T=1111111111
    lT = 1111111111l;
    sTOTP = "67062674";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case T=1234567890
    lT = 1234567890l;
    sTOTP = "91819424";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case T=2000000000
    lT = 2000000000l;
    sTOTP = "90698825";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // SHA256: Test case T=20000000000
    lT = 20000000000l;
    sTOTP = "77737706";
    if(sTOTP.equals(TOTP_Algorithms.TOTP_Code(8, baK, lT, 0, 30, Crypto.HASH_SHA256))) {
      _oLogger.debug(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ T=$2$: $3$", [STRING_TESTCASE, lT, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_Encoding_Hex(_oLogger) {
    var iError = 0;
    var iTest;
    var ba = [0x11, 0x21, 0x31, 0x41, 0x51, 0x61, 0x71, 0x81, 0x91, 0x01, 0xA1, 0xB1, 0xC1]b;
    var s;

    // Hex: Text case 1
    iTest = 1;
    s = "11213141516171819101A1B1C1";
    if(ba.equals(LangUtils.ByteArray_fromHex(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Hex: Text case 2
    iTest = 2;
    s = "11:21:31:41:51:61:71:81:91:01:a1:b1:c1";
    if(ba.equals(LangUtils.ByteArray_fromHex(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Hex: Text case 3
    iTest = 3;
    s = "1121 3141 51617181 9101A1B1C1";
    if(ba.equals(LangUtils.ByteArray_fromHex(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_Encoding_Base32(_oLogger) {
    var iError = 0;
    var iTest;
    var ba = [0x11, 0x21, 0x31, 0x41, 0x51, 0x61, 0x71, 0x81, 0x91, 0x01, 0xA1, 0xB1, 0xC1]b;
    var s;

    // Base32: Text case 1
    iTest = 1;
    s = "CEQTCQKRMFYYDEIBUGY4C===";
    if(ba.equals(LangUtils.ByteArray_fromBase32(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Base32: Text case 2
    iTest = 2;
    s = "CEQT CQKR MFYY DEIB UGY4 C===";
    if(ba.equals(LangUtils.ByteArray_fromBase32(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Base32: Text case 3
    iTest = 3;
    s = "ceqt cqkrm fyydeib ugy4c";
    if(ba.equals(LangUtils.ByteArray_fromBase32(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

  (:test)
    function unitTest_Encoding_Base64(_oLogger) {
    var iError = 0;
    var iTest;
    var ba = [0x11, 0x21, 0x31, 0x41, 0x51, 0x61, 0x71, 0x81, 0x91, 0x01, 0xA1, 0xB1, 0xC1]b;
    var s;

    // Base64: Text case 1
    iTest = 1;
    s = "ESExQVFhcYGRAaGxwQ==";
    if(ba.equals(LangUtils.ByteArray_fromBase64(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Base64: Text case 2
    iTest = 2;
    s = "ESEx QVFh cYGR AaGx wQ==";
    if(ba.equals(LangUtils.ByteArray_fromBase64(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Base64: Text case 3
    iTest = 3;
    s = "ESEx QVFhc YGRAaG xwQ";
    if(ba.equals(LangUtils.ByteArray_fromBase64(s))) {
      _oLogger.debug(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_PASS]));
    }
    else {
      _oLogger.error(Lang.format("$1$ $2$: $3$", [STRING_TESTCASE, iTest, STRING_FAIL]));
      iError++;
    }

    // Done
    return iError == 0;
  }

}
