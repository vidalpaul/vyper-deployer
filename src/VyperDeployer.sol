// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

///@title VyperDeployer
///@author vidalpaul
///@notice vyper_deployer is a contract that allows you to deploy Vyper contracts from a Solidity script

///@notice This cheat codes interface is named _CheatCodes so you can use the CheatCodes interface in other testing files without errors
interface _CheatCodes {
    function ffi(string[] calldata) external returns (bytes memory);
}

contract VyperDeployer {
    address constant HEVM_ADDRESS =
        address(bytes20(uint160(uint256(keccak256("hevm cheat code")))));

    string private constant ERR_CONTRACT_DEPLOYMENT_FAILED =
        "VyperDeployer could not deploy the contract";
    string private constant VYPER_COMPILER = "vyper";
    string private constant VYPER_FILE_EXTENSION = ".vy";

    string public vyperSrcPrefix;

    /// @notice Initializes cheat codes in order to use ffi to compile Vyper contracts
    _CheatCodes cheatCodes = _CheatCodes(HEVM_ADDRESS);

    event ContractDeployed(
        address indexed contractAddress,
        string indexed fileName
    );

    constructor(string memory _vyperSrcPrefix) {
        vyperSrcPrefix = _vyperSrcPrefix;
    }

    ///@notice Compiles a Vyper contract and returns the bytecode
    ///@notice If compilation fails, an error will be thrown
    ///@param fileName - The file name of the Vyper contract
    ///@return bytecode - The bytecode of the Vyper contract
    function compileVyperContract(
        string memory fileName
    ) internal returns (bytes memory) {
        string[] memory cmds = new string[](2);
        cmds[0] = VYPER_COMPILER;
        cmds[1] = string.concat(vyperSrcPrefix, fileName, VYPER_FILE_EXTENSION);
        return cheatCodes.ffi(cmds);
    }

    ///@notice Compiles a Vyper contract and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Vyper contract. For example, the file name for "SimpleStore.vy" is "SimpleStore"
    ///@return deployedAddress - The address that the contract was deployed to

    function deployContractWithoutConstructorArguments(
        string memory fileName
    ) public returns (address) {
        bytes memory bytecode = compileVyperContract(fileName);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice deploy the bytecode with the create instruction
        return deployContract(bytecode, fileName);
    }

    ///@notice Compiles a Vyper contract with constructor arguments and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Vyper contract. For example, the file name for "SimpleStore.vy" is "SimpleStore"
    ///@return deployedAddress - The address that the contract was deployed to
    function deployContractWithConstructorArguments(
        string memory fileName,
        bytes calldata args
    ) public returns (address) {
        ///@notice add args to the deployment bytecode
        bytes memory bytecode = abi.encodePacked(
            compileVyperContract(fileName),
            args
        );

        ///@notice deploy the bytecode with the create instruction
        return deployContract(bytecode, fileName);
    }

    ///@notice Deploys a contract with the create instruction
    ///@param bytecode - The bytecode of the contract to be deployed
    ///@return deployedAddress - The address that the contract was deployed to
    function deployContract(
        bytes memory bytecode,
        string memory fileName
    ) public returns (address) {
        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(deployedAddress != address(0), ERR_CONTRACT_DEPLOYMENT_FAILED);

        emit ContractDeployed(deployedAddress, fileName);

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }
}
