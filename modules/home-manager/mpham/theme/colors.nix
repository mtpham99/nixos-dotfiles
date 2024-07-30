# colors.nix

{ lib, ... }:
let
  hexDigitToInt = hexDigit: let
    digits = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ];
  in
    lib.lists.findFirstIndex (c: c == (lib.strings.toUpper hexDigit)) null digits;

  hexStrToInt = hexStr: let
    hexDigitChars = lib.strings.stringToCharacters hexStr;
  in lib.lists.foldl' (total: hexDigit: total * 16 + (hexDigitToInt hexDigit)) 0 hexDigitChars;
in
{
  # colors

  border = "94BDEDFF";
  border-inactive = "3D3D3DFF";

  text = "FFFFFFFF";
  text-highlight = "FF0000FF";
  background = "000000AA";

  error = "FF0000FF";


  # helper functions

  hexStrToInt = hexStrToInt;

  toCssRgba = hex-color: let
    r = hexStrToInt (builtins.substring 0 2 hex-color);
    g = hexStrToInt (builtins.substring 2 2 hex-color);
    b = hexStrToInt (builtins.substring 4 2 hex-color);
    a = (hexStrToInt (builtins.substring 6 2 hex-color)) / 255.0;
  in "rgba(${builtins.toString r}, ${builtins.toString g}, ${builtins.toString b}, ${builtins.toString a})";

  rgbaToRgb = hex-color: builtins.substring 0 6 hex-color;
  getAlpha = hex-color: builtins.substring 6 2 hex-color;
}
