import 'package:flutter/material.dart';

class Block {
  final String _dbgName;
  final String _faceDbgName;

  String get dbgName => _dbgName;
  String get faceDbgName => _faceDbgName;

  Color color;

  Block(this._dbgName, this._faceDbgName, this.color);

  @override
  String toString() {
    return "$_faceDbgName ($_dbgName)";
  }
}