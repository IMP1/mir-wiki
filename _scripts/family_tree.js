function createFamilyTree(me, parents, siblings, children) {
    const SVGNS = "http://www.w3.org/2000/svg";

    let olderSiblings = [];
    let youngerSiblings = [];

    let svg = document.getElementById("family-tree");
    svg.setAttribute("xmlns", SVGNS);

    parents.forEach(function(p, i) {

        let x = 80 + i * 60;
        let y = 80;

        let group = document.createElementNS(SVGNS, "g");
        group.setAttributeNS(null, "transform", "translate(" + x + " " + y + ")");

        let name = document.createElementNS(SVGNS, "text");
        name.setAttributeNS(null, "transform", "translate(0 0)");
        name.setAttributeNS(null, "fill", "#000");
        name.textContent = p.name;

        let lifespan = document.createElementNS(SVGNS, "text");
        lifespan.setAttributeNS(null, "transform", "translate(0 24)");
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