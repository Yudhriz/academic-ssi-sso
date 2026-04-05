# Alur Autentikasi SIOPv2 (Single Sign-On)
Dokumen ini menjelaskan urutan interaksi (*sequence*) antara Mobile Wallet mahasiswa dan Sistem ELENA untuk melakukan Login Tanpa Password (SSO).

## Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor M as Mahasiswa
    participant W as Mobile Wallet (Holder)
    participant E as ELENA (Verifier)
    participant B as Blockchain (Registry)

    M->>E: Mengklik tombol "Login with SSI"
    E->>W: Mengirim Authentication Request (Termasuk Nonce/Challenge acak)
    W->>M: Menampilkan persetujuan Login (Approve/Reject)
    M->>W: Klik "Approve"
    W->>W: Melakukan tanda tangan (Sign) pada Nonce menggunakan Private Key
    W->>E: Mengirim SIOP Response (Tanda tangan Nonce + JSON VC Utuh)
    
    rect rgb(240, 248, 255)
        Note over E,B: Fase Verifikasi
        E->>E: Verifikasi Off-chain: Cek validitas Tanda Tangan & Kecocokan Nonce
        E->>E: Deterministic Stringify pada JSON VC -> Hash (keccak256)
        E->>B: Panggil verifyCredential(hash)
        B-->>E: Return boolean (true = valid, false = revoked)
    end
    
    alt Status == true
        E-->>M: Login Sukses, masuk ke Dashboard ELENA
    else Status == false
        E-->>M: Login Gagal, Kredensial tidak valid / dicabut
    end
```