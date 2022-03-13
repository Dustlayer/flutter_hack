class Block {
  final String _dbgName;
  final String _faceDbgName;

  String get dbgName => _dbgName;
  String get faceDbgName => _faceDbgName;

  Block(this._dbgName, this._faceDbgName);

  factory Block.dummy() => Block("", "");

  @override
  String toString() {
    return "$_faceDbgName ($_dbgName)";
  }
}