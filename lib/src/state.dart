part of "package:telnet/telnet.dart";


enum _CodeState {
  normal,
  iac,
  opt,
  subOpt,
}