function [padding_SF, backplate_SF] = compute_backplate_SF (components, spring, user, hdpe)
    backplate = components.backplate;
    padding = components.padding;
    adjustment = components.adjustment;
    frontplate = components.frontplate;

    %Padding:
    backplate.friction = spring.y + backplate.mass*2 + adjustment.mass*2 + frontplate.mass*2;
    backplate.load = spring.y*(user.waist_radius*2/2+0.160) / (-2*backplate.height/3);
    
    padding.area_total = backplate.load/padding.pressure;
    
    %assuming 85% of the back plate is covered in padding:
    padding_SF = (padding.area)/padding.area_total;
    
    %Back plate thickness:
    backplate.M = backplate.load*backplate.height/2;
    backplate.c = backplate.thickness/2;
    backplate.I = backplate.thickness^3*backplate.width/12;
    backplate.bending = backplate.M*backplate.c/backplate.I;
    
    backplate_SF =  hdpe.bending/backplate.bending;
end