import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;

  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  const contractName = 'TreasureEntities';

  log("-------- Deploying Entities")
  await deploy(contractName, {
    from: deployer,
    contract: "/src/Container/TreasureEntities.sol:TreasureEntities",
    args: [''],
    log: true,
    autoMine: false, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });
};

export default func;
func.tags = ['all entities'];
