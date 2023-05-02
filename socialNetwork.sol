// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DecentralizedSocialNetwork {
    using SafeMath for uint256;

    struct Post {
        address payable owner;
        string content;
        uint256 likes;
        uint256 rewards;
    }

    uint256 internal postCount = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    uint256 internal rewardPerLike = 1e18; // 1 CELO

    mapping(uint256 => Post) internal posts;

    function createPost(string memory _content) public {
        Post storage newPost = posts[postCount];
        newPost.owner = payable(msg.sender);
        newPost.content = _content;
        newPost.likes = 0;
        newPost.rewards = 0;

        postCount++;
    }

    function getPost(uint256 _postId) public view returns (
        address payable,
        string memory,
        uint256,
        uint256
    ) {
        require(_postId < postCount, "Invalid post ID");

        Post memory post = posts[_postId];
        return (
            post.owner,
            post.content,
            post.likes,
            post.rewards
        );
    }

    function likePost(uint256 _postId) public {
        require(_postId < postCount, "Invalid post ID");

        Post storage post = posts[_postId];
        require(post.owner != msg.sender, "You cannot like your own post");

        post.likes = post.likes.add(1);
        post.rewards = post.rewards.add(rewardPerLike);

        IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            post.owner,
            rewardPerLike
        );
    }

    function getPostCount() public view returns (uint256) {
        return postCount;
    }
}
