function createFamilyTree(me, parents, siblings, children) {
    const SVGNS = "http://www.w3.org/2000/svg";

    let olderSiblings = [];
    let youngerSiblings = [];

    let svg = document.getElementById("family-tree");
    svg.setAttribute("xmlns", SVGNS);

    parents.forEach(function(p) {
        let group = document.createElementNS(SVGNS, "g");

        let x = 20;
        let y = 20;

        let name = document.createElementNS(SVGNS, "text");
        name.setAttributeNS(null, "x", x);
        name.setAttributeNS(null, "y", y);
        name.setAttributeNS(null, "fill", "#000");
        name.textContent = p.name;

        let lifespan = document.createElementNS(SVGNS, "text");
        lifespan.setAttributeNS(null, "x", x);
        lifespan.setAttributeNS(null, "y", y + 24);
        lifespan.setAttributeNS(null, "fill", "#000");
        lifespan.textContent = yearFromBirthdate(p.birthdate);
        if (p.deathdate) {
            lifespan.textContent += " - " + yearFromBirthdate(p.deathdate);
        }

        group.appendChild(name);        
        group.appendChild(lifespan);
        svg.appendChild(group);        
    });
}

function yearFromBirthdate(birthdate) {
    return "1991";
}