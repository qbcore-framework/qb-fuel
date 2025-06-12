import { TRANSLATIONS } from "./translations.js";

const $ = (selector) => document.querySelector(selector);

const $post = async (url, data) => {
    if (!url.startsWith("/")) url = `/${url}`;

    const result = await fetch(`https://qb-fuel${url}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data ?? {}),
    });

    try {
        return await result.json();
    } catch (e) {
        return {};
    }
};

class ProgressBar {
    constructor(progress) {
        this.progress = progress;
        this.progressValue = Number(this.progress.dataset.value);
        this.progressMax = Number(this.progress.dataset.max);
        this.progressMin = Number(this.progress.dataset.min);
        this.progressFill = this.progress.querySelector("div");

        this.update();
    }

    update() {
        this.progressValue = Number(this.progress.dataset.value);
        this.progressMax = Number(this.progress.dataset.max);
        this.progressMin = Number(this.progress.dataset.min);

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
        this.progress.dataset.value = value;
        this.update();
    }
}

let LITER_PRICE = 5;
let CURRENT_FUEL = 0;
const MAX_LITER = 100;

$(".progress").dataset.max = MAX_LITER;

const $liter = $("#liter");
const $price = $("#price");
const $form = $("form");
const pb = new ProgressBar($(".progress"));

const updateLimits = () => {
    const $capacity = $("#capacity");
    const maxLiter = MAX_LITER - CURRENT_FUEL;
    $capacity.innerText = CURRENT_FUEL;
    $liter.max = maxLiter;
    $price.max = Math.floor(maxLiter * LITER_PRICE);
    $price.step = LITER_PRICE;
};

const setupTranslations = (language) => {
    document.documentElement.lang = language;
    const translations = TRANSLATIONS[language] ?? TRANSLATIONS["en"];
    const elements = document.querySelectorAll("[data-translations]");

    elements.forEach((element) => {
        const key = element.dataset.translations;
        if (!translations[key]) return;

        if (element.children.length > 0) {
            let translation = translations[key];
            [...element.children].forEach((child) => {
                translation = translation.replace(
                    `%{${child.id}}`,
                    child.outerHTML
                );
            });
            element.innerHTML = translation;
            return;
        }
        element.innerText = translations[key];
    });
};

$liter.addEventListener("input", () => {
    if ($liter.value === "") return ($liter.value = 0);
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
    if ($price.value === "") return ($price.value = 0);
    const price = parseFloat($price.value);
    const liter = Math.floor(price / LITER_PRICE);
    $liter.value = liter;
    pb.setValue(CURRENT_FUEL + liter);
});

$form.addEventListener("submit", (e) => {
    e.preventDefault();

    const liter = parseFloat($liter.value);
    const price = parseFloat($price.value);

    if (liter === 0 || price === 0) {
        return;
    }

    $liter.value = 0;
    $price.value = 0;
    pb.setValue(0);

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

    if (data.action === "setLanguage") {
        setupTranslations(data.language);
    }
});
