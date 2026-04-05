# Arsitektur Sistem & Antarmuka Smart Contract
Sistem SSI-SSO ini menggunakan model **Trust Triangle** (Segitiga Kepercayaan) yang diperkuat dengan Blockchain sebagai lapis keamanan tambahan (*Verifiable Data Registry*).

## 1. Komponen Utama Sistem
1. **Issuer (SISKA Backend):** Bertugas menerbitkan Verifiable Credential (VC) ke mahasiswa dan mencatatkan *Hash* kredensial tersebut ke Blockchain.
2. **Holder (Mobile Wallet):** Bertugas menyimpan VC di dalam perangkat lokal (HP) dan menandatangani *Challenge* saat diminta login.
3. **Verifier (ELENA Backend):** Bertugas memverifikasi tanda tangan kriptografi dari Holder dan mengecek status *Hash* di Blockchain.
4. **Verifiable Data Registry (Smart Contract):** Tempat penyimpanan status kredensial (Valid/Revoked) di jaringan Ethereum Sepolia.

## 2. Antarmuka Smart Contract (ABI Overview)
Kontrak `AcademicCredentialRegistry.sol` didesain secara minimalis untuk menghemat biaya Gas operasional kampus.

- **`registerDID()`**: Digunakan oleh mahasiswa untuk inisialisasi dompet. *(Membutuhkan Gas)*.
- **`issueCredential(bytes32 _hash)`**: Digunakan oleh SISKA untuk mendaftarkan *Hash* ijazah. Hanya dapat dipanggil oleh *Address* admin. *(Membutuhkan Gas)*.
- **`revokeCredential(bytes32 _hash)`**: Digunakan oleh SISKA untuk mencabut akses ijazah/kredensial. *(Membutuhkan Gas)*.
- **`verifyCredential(bytes32 _hash)`**: Digunakan oleh ELENA untuk memeriksa status kredensial saat mahasiswa login. **Fungsi ini bersifat `view` (100% Gratis / 0 Gas).**

## 3. Topologi Jaringan
- **Blockchain Network:** Ethereum Sepolia Testnet
- **Node Provider:** Alchemy
- **Pengembangan:** Node.js, Hardhat v2, Ethers.js v6