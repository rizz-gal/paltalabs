use soroban_sdk::{contract, contractimpl, Address, Env, token};

#[contract]
pub struct YieldFarm {
    admin: Address,
    total_staked: i128,
    reward_rate: i128,
}

#[contractimpl]
impl YieldFarm {
    pub fn initialize(env: Env, admin: Address, reward_rate: i128) {
        env.storage().instance().set(&admin, &admin);
        env.storage().instance().set(&reward_rate, &reward_rate);
        env.storage().instance().set(&total_staked, &0i128);
    }

    pub fn stake(env: Env, user: Address, amount: i128) {
        user.require_auth();
        
        // Transfer tokens to contract
        token::Client::new(&env, &env.current_contract_address())
            .transfer(&user, &env.current_contract_address(), &amount);
        
        // Update user stake
        let current_stake: i128 = env.storage()
            .instance()
            .get(&user)
            .unwrap_or(0);
        let new_stake = current_stake + amount;
        env.storage().instance().set(&user, &new_stake);
        
        // Update total staked
        let total: i128 = env.storage()
            .instance()
            .get(&total_staked)
            .unwrap_or(0);
        let new_total = total + amount;
        env.storage().instance().set(&total_staked, &new_total);
    }

    pub fn unstake(env: Env, user: Address, amount: i128) {
        user.require_auth();
        
        // Check user has sufficient stake
        let current_stake: i128 = env.storage()
            .instance()
            .get(&user)
            .unwrap_or(0);
        require!(current_stake >= amount, "Insufficient stake");
        
        // Calculate rewards
        let reward_rate: i128 = env.storage()
            .instance()
            .get(&reward_rate)
            .unwrap_or(0);
        let rewards = amount * reward_rate / 10000; // Basis points
        
        // Update user stake
        let new_stake = current_stake - amount;
        env.storage().instance().set(&user, &new_stake);
        
        // Update total staked
        let total: i128 = env.storage()
            .instance()
            .get(&total_staked)
            .unwrap_or(0);
        let new_total = total - amount;
        env.storage().instance().set(&total_staked, &new_total);
        
        // Transfer staked amount + rewards back to user
        token::Client::new(&env, &env.current_contract_address())
            .transfer(&env.current_contract_address(), &user, &(amount + rewards));
    }

    pub fn get_stake(env: Env, user: Address) -> i128 {
        env.storage()
            .instance()
            .get(&user)
            .unwrap_or(0)
    }

    pub fn get_total_staked(env: Env) -> i128 {
        env.storage()
            .instance()
            .get(&total_staked)
            .unwrap_or(0)
    }

    pub fn get_reward_rate(env: Env) -> i128 {
        env.storage()
            .instance()
            .get(&reward_rate)
            .unwrap_or(0)
    }
}
