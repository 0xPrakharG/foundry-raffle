// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract InteractionTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    // uint256 entranceFee;
    // uint256 interval;
    address vrfCoordinator;
    // bytes32 gasLane;
    uint256 subscriptionId;
    // uint32 callbackGasLimit;
    address account;
    address link;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        // entranceFee = config.entranceFee;
        // interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        // gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        // callbackGasLimit = config.callbackGasLimit;
        account = config.account;
        link = config.link;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testInteractionsCreateSubsFundSubAddCons() public {
        CreateSubscription createSubscription = new CreateSubscription();
        (subscriptionId, vrfCoordinator) = createSubscription
            .createSubscription(vrfCoordinator, account);

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            vrfCoordinator,
            subscriptionId,
            link,
            account
        );

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subscriptionId,
            account
        );
        bool isConsumerAdded = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .consumerIsAdded(subscriptionId, address(raffle));

        assert(isConsumerAdded);
    }
}
