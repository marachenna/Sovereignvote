# SovereignVote

SovereignVote is a decentralized identity and voting system built on the Stacks blockchain. It provides secure identity registration and verifiable voting mechanisms for governance and community decision-making.

## Features
- **Decentralized Identity Registration**: Users can register their identities with a hash and pay a registration fee.
- **Proposal Creation**: The contract owner can create voting proposals with a title, description, and duration.
- **Secure Voting**: Registered users can vote on active proposals, ensuring one vote per user per proposal.
- **Transparency**: All proposals and vote counts are publicly accessible.
- **Admin Controls**: The contract owner can update registration fees and manage the system.

## Smart Contract Functions
### Public Functions
- `register-user(identity-hash)` - Registers a user with a hashed identity.
- `create-voting-proposal(title, description, duration)` - Creates a new voting proposal.
- `submit-vote(proposal-id, vote)` - Casts a vote (yes/no) on a proposal.
- `update-registration-fee(new-fee)` - Updates the user registration fee (admin-only).

### Read-Only Functions
- `get-proposal(proposal-id)` - Fetches details of a proposal.
- `get-user-info(user)` - Retrieves user registration data.
- `user-has-voted(proposal-id, user)` - Checks if a user has voted on a proposal.
- `get-vote-results(proposal-id)` - Returns the vote count of a proposal.
- `get-registration-fee()` - Fetches the current registration fee.

## Deployment & Usage
1. Deploy the contract to the Stacks blockchain.
2. Users register their identities.
3. The contract owner creates voting proposals.
4. Registered users cast their votes.
5. Vote results can be retrieved anytime.

## License
This project is open-source and available under the MIT License.

