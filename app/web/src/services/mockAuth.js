// mockAuth.js
let loggedIn = false;

export const login = async (username, password) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      loggedIn = true;          // simulate backend setting httpOnly cookie
      resolve({ success: true });
    }, 300);
  });
};

export const logout = async () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      loggedIn = false;         // simulate backend clearing cookie
      resolve({ success: true });
    }, 200);
  });
};

export const checkSession = async () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ loggedIn });    // simulate backend session check
    }, 200);
  });
};
