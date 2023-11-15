у// The 'token_10018' program.
program token_10018.aleo {

	mapping balance: address => u64;
    
	record Token {
		owner: address,
		balance: u64,
	}

	transition mint(amount: u64) -> Token {
		return Token {
			owner: self.caller,
			balance: amount
		};
	}

	transition transfer_private(receiver: address, amount: u64, input: Token) -> (Token, Token) {
		let remaining: u64 = input.balance - amount;
		let caller: Token = Token {
			owner: self.caller,
			balance: remaining,
		};
		let reciepient: Token = Token {
			owner: receiver,
			balance: amount,
		};
		return (caller, reciepient);
	}

	transition transfer_private_to_public(receiver: address, amount: u64, input: Token) -> Token {
		let remaining: u64 = input.balance - amount;
		let caller: Token = Token {
			owner: self.caller,
			balance: remaining,
		};

		return caller then finalize (receiver, amount);
	}

	finalize transfer_private_to_public(receiver: address, amount: u64) {
		let prev: u64 = Mapping::get_or_use(balance, receiver, 0u64);
		Mapping::set(balance, receiver, prev + amount);
	}

	transition transfer_public_to_private(receiver: address, amount: u64) -> Token {
		return Token {
			owner: receiver,
			balance: amount
		} then finalize(self.caller, amount);
	}

	finalize transfer_public_to_private(sender: address, amount: u64) {
		let prev: u64 = Mapping::get(balance, sender);
		Mapping::set(balance, sender, prev - amount);
	}

	transition join(input: Token, input2: Token) -> Token {
		return Token {
			owner: self.caller,
			balance: input.balance + input2.balance,
		};
	}

}