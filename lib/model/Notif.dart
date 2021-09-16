class Notif {
  int id;
  int receiverId;
  int? sender;
  int subPekerjaanId;
  String nama;
  String status;
  int idPekerjaan;
  String date;
  int isRead;

  Notif(
      {required this.id,
      required this.receiverId,
      required this.subPekerjaanId,
      required this.nama,
      required this.status,
      required this.idPekerjaan,
      required this.date,
      required this.isRead,
      this.sender});

  factory Notif.fromJson(Map<String, dynamic> map) {
    return Notif(
        id: map['id'],
        receiverId: map['receiver_id'],
        subPekerjaanId: map['subpekerjaan_id'],
        nama: map['nama'],
        status: map['status'],
        idPekerjaan: map['id_pekerjaan'],
        date: map['date'],
        isRead: map['is_read'],
        sender: map['sender']);
  }
}
