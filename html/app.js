const $ = (selector) => document.querySelector(selector);

const $post = async (url, data) => {
    if (!url.startsWith("/")) url = `/${url}`;

    const result = await fetch(`https://skys_fuel${url}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
    });

    return await result.json();
};

class ProgressBar {
    constructor(progress) {
        this.progress = progress;
        this.progressValue = this.progress.dataset.value;
        this.progressMax = this.progress.dataset.max;
        this.progressMin = this.progress.dataset.min;
        this.progressFill = this.progress.querySelector("div");

        this.update();
    }

    update() {
        if (this.progressValue > this.progressMax) {
            this.progressValue = this.progressMax;
        }

        if (this.progressValue < this.progressMin) {
            this.progressValue = this.progressMin;
        }

        this.progressFill.style.height = `${
            (this.progressValue / this.progressMax) * 100
        }%`;
    }

    setValue(value) {
        this.progressValue = value;
        this.update();
    }
}

let LITER_PRICE = 5;
let CURRENT_FUEL = 0;
const MAX_LITER = 100;
const $liter = $("#liter");
const $price = $("#price");
const $capacity = $("#capacity");
const $form = $("form");
const pb = new ProgressBar($(".progress"));

const updateLimits = () => {
    $capacity.innerText = MAX_LITER - CURRENT_FUEL;
    $liter.max = MAX_LITER;
    $price.max = Math.floor(MAX_LITER * LITER_PRICE);
};

$liter.addEventListener("input", () => {
    let liter = parseFloat($liter.value);
    if (liter > MAX_LITER) {
        $liter.value = MAX_LITER;
        liter = MAX_LITER;
    }
    const price = Math.floor(liter * LITER_PRICE);
    $price.value = price;
    pb.setValue(CURRENT_FUEL + liter);
});

$price.addEventListener("input", () => {
    const price = parseFloat($price.value);
    const liter = Math.floor(price / LITER_PRICE);
    $liter.value = liter;
    pb.setValue(CURRENT_FUEL + liter);
});

$form.addEventListener("submit", (e) => {
    e.preventDefault();

    const liter = parseFloat($liter.value);
    const price = parseFloat($price.value);

    $liter.value = 0;
    $price.value = 0;
    pb.setValue(0);

    if (liter === 0 || price === 0) {
        return;
    }

    $post("/refill", { liter });
});

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
        $post("/close");
    }
});

window.addEventListener("message", ({ data }) => {
    if (data.action === "show") {
        LITER_PRICE = data.price;
        CURRENT_FUEL = data.currentFuel;
        pb.setValue(CURRENT_FUEL);
        updateLimits();
        $("body").style.display = "block";
    }

    if (data.action === "hide") {
        $("body").style.display = "none";
    }
});
