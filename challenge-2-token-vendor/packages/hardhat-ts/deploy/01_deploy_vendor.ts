import { DeployFunction } from 'hardhat-deploy/types';
import { parseEther } from 'ethers/lib/utils';
import { HardhatRuntimeEnvironmentExtended } from 'helpers/types/hardhat-type-extensions';
import { ethers } from 'hardhat';

const func: DeployFunction = async (hre: HardhatRuntimeEnvironmentExtended) => {
  const { getNamedAccounts, deployments } = hre as any;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // You might need the previously deployed yourToken:
  const yourToken = await ethers.getContract('YourToken', deployer);

  // Todo: deploy the vendor

  await deploy('Vendor', {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [yourToken.address],
    log: true,
  });

  const vendor = await ethers.getContract("Vendor", deployer);

  // Todo: transfer the tokens to the vendor
  console.log("\n 🏵  Sending all 1000 tokens to the vendor...\n");

  var tx = await yourToken.transfer(
    vendor.address,
    ethers.utils.parseEther("1000")
  );
  await tx.wait();

  await vendor.transferOwnership("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
};
export default func;
func.tags = ['Vendor'];
