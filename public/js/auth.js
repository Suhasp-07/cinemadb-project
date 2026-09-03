// Simple client-side session gate for this demo.
// Not real security (no server session/token) — just keeps the UI flow sensible:
// pages other than login.html redirect back to login if no one has signed in yet.
(function () {
  const isLoginPage = window.location.pathname.endsWith("login.html");
  const signedIn = sessionStorage.getItem("cinemadb_user");

  if (!isLoginPage && !signedIn) {
    window.location.href = "/login.html";
  }
})();

function wireLogout() {
  const logoutLink = document.getElementById("logout-link");
  if (!logoutLink) return;
  logoutLink.addEventListener("click", (e) => {
    e.preventDefault();
    sessionStorage.removeItem("cinemadb_user");
    window.location.href = "/login.html";
  });
}
document.addEventListener("DOMContentLoaded", wireLogout);
