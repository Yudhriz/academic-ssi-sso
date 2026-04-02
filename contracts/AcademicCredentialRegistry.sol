// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AcademicCredentialRegistry
 * @dev Prototipe Smart Contract untuk Skripsi SSI-SSO.
 * Bertindak sebagai Verifiable Data Registry.
 */
contract AcademicCredentialRegistry {
    // Menyimpan alamat kampus (Issuer) agar tidak sembarang orang bisa menerbitkan ijazah/VC
    address public adminIssuer;

    // Struktur data
    struct Credential {
        bytes32 credentialHash;
        address issuer;
        uint256 issuedAt; // Akan sangat berguna untuk grafik Bab 4 (Lifecycle)
        bool revoked;
    }

    // Mapping 1: Untuk mencatat mahasiswa yang sudah memiliki DID (TS001)
    mapping(address => bool) public registeredDIDs;

    // Mapping 2: Database utama untuk menyimpan Hash Ijazah/Credential
    mapping(bytes32 => Credential) public credentials;

    // Events: Ini adalah "notifikasi" untuk Backend agar database off-chain sinkron
    event DIDRegistered(address indexed didAddress);
    event CredentialIssued(bytes32 indexed credentialHash, address indexed issuer);
    event CredentialRevoked(bytes32 indexed credentialHash);

    // Modifier: Keamanan agar hanya kampus (admin) yang bisa menambah/mencabut VC
    modifier onlyIssuer() {
        require(msg.sender == adminIssuer, "Akses Ditolak: Hanya Issuer/Kampus");
        _;
    }

    // Dijalankan sekali saat contract di-deploy
    constructor() {
        adminIssuer = msg.sender; // Akun yang mendeploy otomatis menjadi Admin
    }

    /**
     * @dev Fungsi 1: Register DID (TS001)
     * Mahasiswa mendaftarkan wallet mereka ke sistem kampus.
     */
    function registerDID() public {
        require(!registeredDIDs[msg.sender], "DID sudah terdaftar di sistem");
        
        registeredDIDs[msg.sender] = true;
        
        emit DIDRegistered(msg.sender);
    }

    /**
     * @dev Fungsi 2: Issue Credential (TS002)
     * Kampus menerbitkan Hash Ijazah/Status Mahasiswa ke Blockchain.
     */
    function issueCredential(bytes32 _hash) public onlyIssuer {
        // Mencegah duplikasi data
        require(credentials[_hash].issuedAt == 0, "Hash Credential sudah terdaftar");

        // Menyimpan data ke dalam struct
        credentials[_hash] = Credential({
            credentialHash: _hash,
            issuer: msg.sender,
            issuedAt: block.timestamp, // Mengambil waktu server blockchain saat ini
            revoked: false
        });

        emit CredentialIssued(_hash, msg.sender);
    }

    /**
     * @dev Fungsi 3: Revoke Credential (TS004)
     * Kampus mencabut kredensial (misal: mahasiswa DO atau lulus).
     */
    function revokeCredential(bytes32 _hash) public onlyIssuer {
        require(credentials[_hash].issuedAt != 0, "Credential tidak ditemukan");
        require(!credentials[_hash].revoked, "Credential ini sudah dicabut sebelumnya");

        credentials[_hash].revoked = true;

        emit CredentialRevoked(_hash);
    }

    /**
     * @dev Fungsi 4: Verify Credential (TS003)
     * Digunakan oleh ELENA untuk memvalidasi login mahasiswa.
     * Menggunakan 'view' agar tidak memakan Gas (Gratis dipanggil).
     */
    function verifyCredential(bytes32 _hash) public view returns (bool) {
        require(credentials[_hash].issuedAt != 0, "Credential tidak ditemukan di Blockchain");
        
        // Logika sederhana: Jika tidak di-revoke, maka valid (return true)
        return credentials[_hash].revoked == false;
    }
}