//Programmed by Parinaz Soltanzadeh
%{
    #include <stdio.h>
    #include <string.h>
    #include <math.h>
  
    void yyerror(char const *s);
    extern int yylex(void);
    const float w = 100;
    //w=2pif(w is omega)
    enum component{comres,comind,comcap};
    //functions
    void info(enum component type,int index);
    void Quant(enum component type,int index,int num);
    float ImpedanceCal(int num);
    void MadarCal(int s);
    //global variables
    int s;
    int x=2;
    int lastimp = 1;

    float t;
    float r;
    //structs
    struct Component{
        enum component type; 
        int number;
        int id; 
        }value[100];

    struct Impedance{
        float value;
        float imag;
    }imp[100];
%}

//tokens

%token Resistor Inductor Capacitor
%token NUMBER

%token OP
%token SeriOp MovaziOp

%token END

%%
//Grammers

Input: /* empty */;
Input: Input Line;

Line: Expression END {  printf("Finish \n"); }
;
Expression:  Resistor NUMBER{$$=$2;  printf("I found Resistor . Index is : %d\n", $$);info(comres,$2);}
          | Inductor NUMBER{ $$=$2; printf("I found Inductor . Index is : %d\n",$$);info(comind,$2);}
          | Capacitor NUMBER{$$=$2; printf("I found Capacitor. Index is: %d\n",$$);info(comcap,$2);}

;

Expression: Expression2{MadarCal($1);};

Expression: Resistor NUMBER OP NUMBER { $$=$2; printf("I found Resistor. Index is : %d Quantification: %d\n", $2, $4); Quant(comres,$2,$4);ImpedanceCal($2);};
Expression: Inductor NUMBER OP NUMBER { $$=$2; printf("I found Inductor. Index is : %d Quantification: %d\n", $2, $4);  Quant(comind,$2,$4);ImpedanceCal($2);};
Expression: Capacitor NUMBER OP NUMBER { $$=$2; printf("I found Capacitor. Index is: %d Quantification: %d\n", $2 , $4);  Quant(comcap,$2,$4);ImpedanceCal($2);};

Expression2: Expression SeriOp Expression {  printf("This is Seri!  \n");s =1; $$ = s;};
Expression2: Expression MovaziOp  Expression {  printf("This is Movazi!  \n");s = 2; $$ = s; };

%%
//functions
//sum of impedances / seri or movazi
void MadarCal(int s){
    
    switch(s){
        case 1:
        //Seri
                imp[lastimp].value = imp[x].value+imp[x-1].value ;
                imp[lastimp].imag = imp[x].imag+imp[x-1].imag; 
                imp[x].value = imp[lastimp].value;
                imp[x].imag = imp[lastimp].imag;
               
        break;
        case 2:
        //Movazi
            t=1/imp[x-1].value;
            r=1/imp[x-1].imag;
            
            if(imp[x].value == 0 && imp[x-1].value == 0){
                imp[lastimp].value+=0;
                t=0;
            }
            else if(imp[x].value==0 && imp[x-1].value !=0){
                imp[lastimp].value = 1/t;
                t=1/t;
            }

            else if(imp[x-1].value ==0 && imp[x].value!=0){
                t=1/(imp[x].value);
                imp[lastimp].value = 1/t;
                t=1/t;
            }
            else{
                
                imp[lastimp].value = 1/((1/(imp[x].value)) + t);
                t=imp[lastimp].value;
            }
                
            if(imp[x].imag == 0 && imp[x-1].imag == 0){
                imp[lastimp].imag +=0;
                r=0;
            }
            else if(imp[x].imag==0 && imp[x-1].imag !=0){
                imp[lastimp].imag =1/r;
                r=1/r;
            }
            else if(imp[x-1].imag ==0 && imp[x].imag!=0){
                r = 1/(imp[x].imag);
                imp[lastimp].imag = 1/r;
                r=1/r;
            }
            else{
               
                imp[lastimp].imag = 1/((1/(imp[x].imag)) + r);
                r=imp[lastimp].imag;
            }
                
            imp[x].value = t;
            imp[x].imag = r;
        break;
    }
    printf("\nImpedance= %f + %f j ; \n",imp[lastimp].value,imp[lastimp].imag);
   x++;
}
//Information of components
void info(enum component type , int index){
        value[index].type = type;
        value[index].id = index;    
}
//Quantification of each component
void Quant(enum component type,int index, int num){
    value[index].type = type;
    value[index].id = index; 
    value[index].number = num;
    //printf("\n %d %d",(int)index,(int)num,"\n");
}
//Impedance Calculation for each component
float ImpedanceCal(int num){
    switch(value[num].type){
        case comres:
            imp[lastimp].value = value[num].number;
            imp[lastimp].imag = 0; 
            
        break;
        case comind:
            imp[lastimp].value = 0;
            imp[lastimp].imag = (value[num].number) * w;
            
        break;
        case comcap:
            imp[lastimp].value =  0;
            imp[lastimp].imag = 1/((value[num].number)*w * (-1));
            
        break;
    }
    lastimp++;
    
    return lastimp-1;
}

//yyerror function
void yyerror(char const *s) {
  printf("%s\n", s);
}
//main
int main() {
    int ret = yyparse();
    if (ret){
	fprintf(stderr, "%d error found.\n",ret);
    }
    return 0;
}