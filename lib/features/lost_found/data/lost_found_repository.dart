import '../models/lost_found_models.dart';

abstract interface class LostFoundRepository {
  List<LostFoundItem> loadItems();
}

class InMemoryLostFoundRepository implements LostFoundRepository {
  const InMemoryLostFoundRepository();

  @override
  List<LostFoundItem> loadItems() {
    return [
      LostFoundItem(
        id: 'LF-1001',
        title: 'Laptop Lenovo ThinkPad',
        type: ItemType.found,
        category: ItemCategory.electronics,
        location: 'Lobby Utama',
        description:
            'Ditemukan di sofa dekat meja resepsionis. Kondisi menyala, terdapat stiker inventaris di bagian belakang.',
        reportedBy: 'Bima - Keamanan',
        contact: 'ext. 110',
        reportedAt: DateTime(2026, 7, 3, 8, 40),
        status: ItemStatus.claimReview,
        priority: ItemPriority.high,
        claim: ClaimRecord(
          claimantName: 'Rafi Pratama',
          contact: 'rafi.pratama@example.com',
          note:
              'Mengaku tertinggal setelah meeting pagi dan dapat menyebutkan nomor stiker inventaris.',
          submittedAt: DateTime(2026, 7, 3, 10, 15),
          status: ClaimStatus.waiting,
        ),
        activities: [
          ActivityLog(
            message: 'Klaim masuk dan perlu ditinjau',
            actor: 'Meja Resepsionis',
            timestamp: DateTime(2026, 7, 3, 10, 15),
          ),
          ActivityLog(
            message: 'Barang diterima oleh petugas',
            actor: 'Bima - Keamanan',
            timestamp: DateTime(2026, 7, 3, 8, 40),
          ),
        ],
      ),
      LostFoundItem(
        id: 'LF-1002',
        title: 'Dompet Kulit Cokelat',
        type: ItemType.lost,
        category: ItemCategory.bags,
        location: 'Kantin Lantai 2',
        description:
            'Dompet berisi kartu identitas, kartu akses, dan beberapa kartu bank. Pelapor terakhir makan siang di area kantin.',
        reportedBy: 'Nadia Putri',
        contact: '+62 812 0000 2210',
        reportedAt: DateTime(2026, 7, 2, 13, 5),
        status: ItemStatus.open,
        priority: ItemPriority.high,
        activities: [
          ActivityLog(
            message: 'Laporan kehilangan dibuat',
            actor: 'Nadia Putri',
            timestamp: DateTime(2026, 7, 2, 13, 5),
          ),
        ],
      ),
      LostFoundItem(
        id: 'LF-1003',
        title: 'Kartu Akses Biru',
        type: ItemType.found,
        category: ItemCategory.keys,
        location: 'Lift Barat',
        description:
            'Kartu akses tanpa nama ditemukan di lantai lift. Tim keamanan sedang mencocokkan nomor seri.',
        reportedBy: 'Yuni - Facilities',
        contact: 'facilities@example.com',
        reportedAt: DateTime(2026, 7, 2, 9, 20),
        status: ItemStatus.matched,
        priority: ItemPriority.normal,
        activities: [
          ActivityLog(
            message: 'Nomor kartu cocok dengan data karyawan',
            actor: 'Staff Lost and Found',
            timestamp: DateTime(2026, 7, 2, 11, 0),
          ),
          ActivityLog(
            message: 'Barang ditemukan di Lift Barat',
            actor: 'Yuni - Facilities',
            timestamp: DateTime(2026, 7, 2, 9, 20),
          ),
        ],
      ),
      LostFoundItem(
        id: 'LF-1004',
        title: 'Payung Lipat Abu',
        type: ItemType.found,
        category: ItemCategory.other,
        location: 'Ruang Rapat Cendana',
        description:
            'Payung lipat warna abu dengan gagang hitam. Ditemukan setelah sesi onboarding karyawan baru.',
        reportedBy: 'Alya - People Ops',
        contact: 'people.ops@example.com',
        reportedAt: DateTime(2026, 7, 1, 17, 35),
        status: ItemStatus.returned,
        priority: ItemPriority.low,
        activities: [
          ActivityLog(
            message: 'Barang dikembalikan kepada pemilik',
            actor: 'Staff Lost and Found',
            timestamp: DateTime(2026, 7, 2, 8, 50),
          ),
          ActivityLog(
            message: 'Laporan barang ditemukan dibuat',
            actor: 'Alya - People Ops',
            timestamp: DateTime(2026, 7, 1, 17, 35),
          ),
        ],
      ),
      LostFoundItem(
        id: 'LF-1005',
        title: 'Jaket Denim',
        type: ItemType.lost,
        category: ItemCategory.clothing,
        location: 'Auditorium',
        description:
            'Jaket denim biru tertinggal saat town hall. Laporan lama sudah diarsipkan setelah tidak ada pembaruan.',
        reportedBy: 'Damar Wibowo',
        contact: 'damar@example.com',
        reportedAt: DateTime(2026, 6, 28, 19, 10),
        status: ItemStatus.archived,
        priority: ItemPriority.normal,
        activities: [
          ActivityLog(
            message: 'Laporan diarsipkan',
            actor: 'Staff Lost and Found',
            timestamp: DateTime(2026, 7, 3, 16, 10),
          ),
          ActivityLog(
            message: 'Laporan kehilangan dibuat',
            actor: 'Damar Wibowo',
            timestamp: DateTime(2026, 6, 28, 19, 10),
          ),
        ],
      ),
    ];
  }
}
