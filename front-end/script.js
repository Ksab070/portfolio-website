function toggleMenu() {
    const menu = document.querySelector(".menu-links");
    const icon = document.querySelector(".hamburger-icon");
    const body = document.querySelector("body"); // Get the body element

    menu.classList.toggle("open");
    icon.classList.toggle("open");
    body.classList.toggle("no-scroll"); // Toggle the no-scroll class to prevent background scrolling
}