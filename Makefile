-include .env

.PHONY: all test clean deploy

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network bsctest\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network bsctest\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# install dependencies
install :; forge install foundry-rs/forge-std --no-commit && forge install Cyfrin/foundry-devops --no-commit && forge install https://github.com/chiru-labs/ERC721A.git --no-commit && forge install OpenZeppelin/openzeppelin-contracts --no-commit

# update dependencies
update:; forge update

# compile
build:; forge build

# test
test :; forge test 

# test coverage
coverage:; @forge coverage --contracts src
coverage-report:; @forge coverage --contracts src --report debug > coverage.txt

# take snapshot
snapshot :; forge snapshot

# format
format :; forge fmt

# spin up local test network
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# spin up fork
fork :; @anvil --fork-url ${RPC_BASE_MAIN} --fork-block-number 13383370 --fork-chain-id 8453 --chain-id 123

# deployment
deploy-local: 
	@forge script script/deployment/DeployNFTContract.s.sol:DeployNFTContract --rpc-url localhost --private-key ${DEFAULT_ANVIL_KEY} --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast 

deploy-token-testnet: 
	@forge script script/deployment/DeployERC20Token.s.sol:DeployERC20Token --rpc-url $(RPC_BASE_SEPOLIA) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast --verify --etherscan-api-key $(BASESCAN_KEY) -vvvv

deploy-testnet: 
	@forge script script/deployment/DeployNFTContract.s.sol:DeployNFTContract --rpc-url $(RPC_BASE_SEPOLIA) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast --verify --etherscan-api-key $(BASESCAN_KEY) -vvvv

deploy-mainnet: 
	@forge script script/deployment/DeployNFTContract.s.sol:DeployNFTContract --rpc-url $(RPC_BASE_MAIN) --account EARN-Deployer --sender 0x4397122Ad9602aD358816F1f2De2396e3dCEb857 --broadcast --verify --etherscan-api-key $(BASESCAN_KEY) -vvvv


# interaction
mint-testnet:
	@forge script script/interactions/Interactions.s.sol:MintNft --rpc-url $(RPC_BASE_SEPOLIA) --account Test-Deployer --sender 0x11F392Ba82C7d63bFdb313Ca63372F6De21aB448 --broadcast --etherscan-api-key $(BASESCAN_KEY)


# security
slither :; slither ./src 


-include ${FCT_PLUGIN_PATH}/makefile-external