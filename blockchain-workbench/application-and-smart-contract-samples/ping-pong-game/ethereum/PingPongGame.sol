pragma solidity 0.5.3;

contract Starter
{
    enum StateType { GameProvisioned, Pingponging, GameFinished}

    event StarterString(string s);

    StateType public State;

    string public PingPongGameName;
    address public GameStarter;
    address public GamePlayer;
    int256 public PingPongTimes;

    constructor (string memory gameName) public{
        PingPongGameName = gameName;
        GameStarter = msg.sender;

        GamePlayer = address(new Player(PingPongGameName));

        State = StateType.GameProvisioned;
    }

    function StartPingPong(int256 pingPongTimes) public 
    {
        PingPongTimes = pingPongTimes;

        Player player = Player(GamePlayer);
        State = StateType.Pingponging;

        emit StarterString("<Starter> sending ping");

        player.Ping(pingPongTimes);
    }

    function Pong(int256 currentPingPongTimes) public 
    {
        currentPingPongTimes = currentPingPongTimes - 1;

        Player player = Player(GamePlayer);
        if(currentPingPongTimes > 0)
        {
            State = StateType.Pingponging;
            emit StarterString("<Starter> sending ping");
            player.Ping(currentPingPongTimes);
        }
        else
        {
            emit StarterString("<Starter> finished pingpong");
            State = StateType.GameFinished;
            player.FinishGame();
        }
    }

    function FinishGame() public
    {
        State = StateType.GameFinished;
    }
    
    function () external {
        emit StarterString("Fallback invoked");
    }
}

contract Player
{
    enum StateType {PingpongPlayerCreated, PingPonging, GameFinished}

    StateType public State;

    event PlayerString(string s);

    address public GameStarter;
    string public PingPongGameName;

    constructor (string memory pingPongGameName) public {
        GameStarter = msg.sender;
        PingPongGameName = pingPongGameName;

        State = StateType.PingpongPlayerCreated;
    }

    function Ping(int256 currentPingPongTimes) public 
    {
        currentPingPongTimes = currentPingPongTimes - 1;

        Starter starter = Starter(msg.sender);
        if(currentPingPongTimes > 0)
        {
            State = StateType.PingPonging;
            emit PlayerString("<Player> sending pong");
            starter.Pong(currentPingPongTimes);
        }
        else
        {
            State = StateType.GameFinished;
            emit PlayerString("<Player> finished pingpong");
            starter.FinishGame();
        }
    }

    function FinishGame() public
    {
        State = StateType.GameFinished;
    }
}

contract Driver {

    address public StarterAddr;

    function CreateStarter () public {
        StarterAddr = address(new Starter("pingpong"));
    }

    function DoPingPong (int256 numIterations) public {
        bytes memory data = abi.encodeWithSignature("StartPingPong(int256)", numIterations);
        (bool res, ) = StarterAddr.call(data);
    }
}