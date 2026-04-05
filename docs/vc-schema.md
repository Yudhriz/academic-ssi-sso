# Skema Verifiable Credential (VC) Mahasiswa
Dokumen ini mendefinisikan struktur data standar W3C untuk Kredensial Akademik di lingkungan kampus.

## Format Standar (JSON-LD)
```json
{
  "@context": [
    "[https://www.w3.org/2018/credentials/v1](https://www.w3.org/2018/credentials/v1)"
  ],
  "id": "urn:uuid:<UUID_V4>",
  "type": ["VerifiableCredential", "MahasiswaCredential"],
  "issuer": "did:web:siska.nurulfikri.ac.id",
  "issuanceDate": "YYYY-MM-DDThh:mm:ssZ",
  "credentialSubject": {
    "id": "did:ethr:<WALLET_ADDRESS>",
    "nim": "<STRING>",
    "nama": "<STRING>",
    "status": "AKTIF | LULUS | DO"
  }
}
```
## Penjelasan Properti Data

 Properti                   | Tipe Data | Deskripsi                                 | Aturan Khusus                             
----------------------------|-----------|-------------------------------------------|-------------------------------------------
 `@context`                 | Array     | URL referensi standar dari W3C.           | Wajib ada, tidak boleh diubah.            
 `id`                       | String    | Identifier unik untuk kredensial ini.     | Wajib menggunakan format UUID v4.         
 `type`                     | Array     | Jenis kredensial.                         | Wajib mengandung "VerifiableCredential".  
 `issuer`                   | String    | Identitas pihak yang menerbitkan.         | Menggunakan DID Web kampus (SISKA).       
 `issuanceDate`             | String    | Waktu penerbitan kredensial.              | Format ISO 8601 (UTC).                    
 `credentialSubject.id`     | String    | Identitas pemilik kredensial (Mahasiswa). | Menggunakan DID Ethr (Address Wallet).    
 `credentialSubject.nim`    | String    | Nomor Induk Mahasiswa.                    | -                                         
 `credentialSubject.nama`   | String    | Nama lengkap mahasiswa.                   | -                                         
 `credentialSubject.status` | String    | Status akademik saat ini.                 | Hanya menerima nilai terdefinisi.         

