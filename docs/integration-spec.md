# Spesifikasi Integrasi Sistem SSI-SSO Akademik
**Dokumen Referensi Utama untuk Tim Pengembang (Backend, Mobile, Blockchain)**

## 1. Informasi Smart Contract (Verifiable Data Registry)
- **Network:** Ethereum Sepolia Testnet
- **Contract Name:** `AcademicCredentialRegistry`
- **Contract Address:** `0xa180A866DB8317Ac64B43c4e3AfbD7af82D18e1E`
- **ABI File:** Tersedia di `artifacts/contracts/AcademicCredentialRegistry.sol/AcademicCredentialRegistry.json` *(file untuk Backend)*.
- **Hashing Algorithm Wajib:** `keccak256` (SHA-3). Semua hash harus diawali dengan `0x`.

## 2. Format Verifiable Credential (VC) JSON
Ini adalah format baku yang **WAJIB** di-generate oleh Backend (Issuer) dan disimpan oleh Mobile Wallet (Holder).

```json
{
  "@context": [
    "[https://www.w3.org/2018/credentials/v1](https://www.w3.org/2018/credentials/v1)"
  ],
  "id": "urn:uuid:12345678-1234-1234-1234-123456789012",
  "type": ["VerifiableCredential", "MahasiswaCredential"],
  "issuer": "did:web:siska.nurulfikri.ac.id",
  "issuanceDate": "2026-03-28T11:47:09Z",
  "credentialSubject": {
    "id": "did:ethr:<WALLET_ADDRESS_MAHASISWA>",
    "nim": "12345678",
    "nama": "Nama Mahasiswa",
    "status": "AKTIF"
  }
}
```

## 3. Alur Kerja & Endpoint API (For Backend)
Backend SISKA bertindak sebagai Issuer dan Verifier.

**A. Endpoint Generate DID**

- POST `/generate-did`
- Output: Menyimpan Address wallet mahasiswa ke Database SISKA dan mengembalikan format `did:ethr:<ADDRESS>`.

**B. Endpoint Issue Credential**

- POST `/issue-credential`
- Proses Internal Backend:

  1. Merakit JSON VC seperti format di atas.
  2. Melakukan Deterministic Stringify pada JSON (misal menggunakan library `fast-json-stable-stringify`) agar urutan key dan spasi konsisten.
  3. Melakukan hashing pada string deterministik tersebut menggunakan algoritma `keccak256`.
  4. Memanggil fungsi Smart Contract: `issueCredential(hash)`.

- Output: Mengirimkan JSON VC utuh ke Mobile Wallet.

## 4. Format Respons Wallet untuk SIOPv2 (For Mobile)
Saat ELENA (Verifier) meminta login, ELENA akan mengirimkan sebuah [Nonce](https://www.investopedia.com/terms/n/nonce.asp) (number used only once). Wallet harus merespons dengan format signed payload yang berisi bukti kepemilikan.

- Payload yang dikirim Wallet ke ELENA:

```json
{
  "did": "did:ethr:<WALLET_ADDRESS>",
  "presentation": {
    "vc": "..." // JSON VC utuh
  },
  "signature": "0x..." // Signature kriptografi (ECDSA) dari 'Nonce' ELENA, bukan tanda tangan VC.
}
```

## 5. Alur Verifikasi Akhir (SSO)
Saat ELENA menerima payload dari Wallet, ELENA (Backend) **WAJIB** melakukan dua hal:

1. **Verifikasi Off-chain**: Memastikan `signature` adalah hasil penandatanganan Nonce yang valid dan benar-benar ditandatangani oleh Private Key milik `did` mahasiswa.
2. **Verifikasi On-chain**: Melakukan Deterministic Stringify pada VC, menghitung ulang hash `keccak256`, lalu memanggil fungsi Smart Contract: `verifyCredential(hash)`.
    - Jika true: Login Sukses.
    - Jika false atau error: Login Ditolak.