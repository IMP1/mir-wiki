const SVGNS = "http://www.w3.org/2000/svg";

function createFamilyTree(me, parents, siblings, children) {

    let olderSiblings = [];
    let youngerSiblings = [];

    let svg = document.getElementById("family-tree");
    svg.setAttribute("xmlns", SVGNS);
    svg.setAttribute("height", "320px");
    svg.setAttribute("width", "100%");

    parents.forEach(function(person, i) {
        let x = 120 + i * 120;
        let y = 40;
        drawFamilyMember(svg, person, x, y);
            
    });
    // TODO: draw line between parents
    // TODO: draw line from parents to siblings
    let meX = 0;
    {
        let thisGenerationIndex = 0;
        youngerSiblings.forEach(function(person, i) {
            let x = 60 + i * 120;
            let y = 160;
            drawFamilyMember(svg, person, x, y);
            thisGenerationIndex = i;
        });
        thisGenerationIndex += 1;
        meX = 60 + thisGenerationIndex * 120;
        drawFamilyMember(svg, me, 60 + thisGenerationIndex * 120, 160);
        thisGenerationIndex += 1;
        olderSiblings.forEach(function(person, i) {
            let x = 60 + (thisGenerationIndex + i) * 120;
            let y = 160;
            drawFamilyMember(svg, person, x, y);
        });
    }
    // TODO: draw line from me to children
    children.forEach(function(person, i) {
        let x = 120 + i * 120;
        let y = 280;
        drawFamilyMember(svg, person, x, y);
    });
}

function drawFamilyMember(svg, person, x, y) {
    let group = document.createElementNS(SVGNS, "g");
    group.setAttributeNS(null, "transform", "translate(" + x + " " + y + ")");

    let name = document.createElementNS(SVGNS, "text");
    name.setAttributeNS(null, "transform", "translate(0 0)");
    name.setAttributeNS(null, "fill", "#000");
    name.textContent = person.name;

    let lifespan = document.createElementNS(SVGNS, "text");
    lifespan.setAttributeNS(null, "transform", "translate(0 24)");
    lifespan.setAttributeNS(null, "fill", "#000");
    lifespan.textContent = yearFromBirthdate(person.birthdate);
    if (person.deathdate) {
        lifespan.textContent += " - " + yearFromBirthdate(person.deathdate);
    }

    group.appendChild(name);        
    group.appendChild(lifespan);
    svg.appendChild(group);    
}

function yearFromBirthdate(birthdate) {
    return "1991";
}