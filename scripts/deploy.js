const { ethers } = require("hardhat");

async function main() {
  console.log("Memulai proses deployment kontrak...");

  // Mengambil akun yang akan mendeploy (Akun pertama di Hardhat akan menjadi Admin/Issuer)
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract dengan akun (Admin Issuer):", deployer.address);

  // Mengambil file kontrak yang sudah dicompile tadi
  const Registry = await ethers.getContractFactory("AcademicCredentialRegistry");
  
  // Menanam kontrak ke blockchain
  const registry = await Registry.deploy();
  await registry.waitForDeployment();

  console.log("Sukses! AcademicCredentialRegistry berhasil di-deploy ke alamat:", await registry.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});