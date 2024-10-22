function [padding_SF, backplate_SF] = compute_backplate_SF (components, spring, user, hdpe)
    backplate = components.backplate;
    padding = components.padding;
    adjustment = components.adjustment;
    frontplate = components.frontplate;

    %Padding:
    backplate.friction = spring.y + backplate.mass*2 + adjustment.mass*2 + frontplate.mass*2;
    backplate.load = -2*(spring.y)*(user.waist_radius*2+0.20) / (-1*backplate.height/2);
    backplate.load = backplate.load + abs(-2*(backplate.mass*9.81 + adjustment.mass*9.81 + frontplate.mass*9.81)*(user.waist_radius) / (-1*backplate.height/2));
    
    padding.area_total = abs(backplate.load)/padding.pressure;
    
    %assuming back is in contact with one pad at a time:
    padding_SF = (padding.area)/padding.area_total;
    
    %Back plate thickness:
    backplate.M = backplate.load*backplate.height/2;
    backplate.c = backplate.thickness/2;
    backplate.I = backplate.thickness^3*backplate.width/12;
    backplate.bending = backplate.M*backplate.c/backplate.I;
    
    backplate_SF =  hdpe.bending/abs(backplate.bending);
end