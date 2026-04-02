const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AcademicCredentialRegistry - Pengujian Fungsional Skripsi", function () {
  let registry;
  let adminIssuer;
  let studentWallet;
  
  // Simulasi Hash Ijazah Mahasiswa (Format bytes32)
  const credentialHash = ethers.keccak256(ethers.toUtf8Bytes("NIM-123456-LULUS-2026"));

  // Sebelum tes dimulai, kita deploy dulu kontraknya ke memori lokal
  before(async function () {
    [adminIssuer, studentWallet] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("AcademicCredentialRegistry");
    registry = await Registry.deploy();
    await registry.waitForDeployment();
  });

  it("TS001: Register DID - Mahasiswa mendaftarkan wallet sukses", async function () {
    // Mahasiswa memanggil fungsi register
    await expect(registry.connect(studentWallet).registerDID())
      .to.emit(registry, "DIDRegistered")
      .withArgs(studentWallet.address);

    // Verifikasi status di dalam mapping
    const isRegistered = await registry.registeredDIDs(studentWallet.address);
    expect(isRegistered).to.equal(true);
  });

  it("TS002: Issue Credential - Kampus menerbitkan Hash Ijazah", async function () {
    // Admin kampus memanggil fungsi issue
    await expect(registry.connect(adminIssuer).issueCredential(credentialHash))
      .to.emit(registry, "CredentialIssued")
      .withArgs(credentialHash, adminIssuer.address);

    // Memastikan data masuk dengan benar
    const credData = await registry.credentials(credentialHash);
    expect(credData.revoked).to.equal(false);
    expect(credData.issuer).to.equal(adminIssuer.address);
  });

  it("TS003: Verify Credential - ELENA mengecek Hash (Harus True)", async function () {
    // Siapapun bisa memverifikasi, kita coba panggil fungsinya
    const isValid = await registry.verifyCredential(credentialHash);
    expect(isValid).to.equal(true);
  });

  it("TS004: Revoke Credential - Kampus mencabut Ijazah", async function () {
    // Admin mencabut ijazah
    await expect(registry.connect(adminIssuer).revokeCredential(credentialHash))
      .to.emit(registry, "CredentialRevoked")
      .withArgs(credentialHash);

    // ELENA mengecek lagi, sekarang harusnya gagal (False)
    const isValidAfterRevoke = await registry.verifyCredential(credentialHash);
    expect(isValidAfterRevoke).to.equal(false);
  });
});