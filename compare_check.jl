using DelimitedFiles
f_1 = "1_00__0__0__acopf__1_05"
f_2 = "1_00__0__0__scacopf__1_05"
f_3 = "1_00__0__0__exitrates__1e_15__1_05"
c_1 = "data/"*f_1*"/"
c_2 = "data/"*f_2*"/"
c_3 = "data/"*f_3*"/"
Vm_1 = readdlm(c_1*"Vm.csv",','); Va_1 = readdlm(c_1*"Va.csv",','); V_1 = Vm_1 .* exp.(im .* Va_1)
Vm_2 = readdlm(c_2*"Vm.csv",','); Va_2 = readdlm(c_2*"Va.csv",','); V_2 = Vm_2 .* exp.(im .* Va_2)
Vm_3 = readdlm(c_3*"Vm.csv",','); Va_3 = readdlm(c_3*"Va.csv",','); V_3 = Vm_3 .* exp.(im .* Va_3)
Im_1 = zeros(186)
Im_2 = zeros(186)
Im_3 = zeros(186)

Vm = Vm_1
Va = Va_1
Im = Im_1

for i in eachindex(Im)
f = line.from; t = line.to
f_idx = first(findall(opfmodeldata[:buses].bus_i .== line.from)); t_idx = first(findall(opfmodeldata[:buses].bus_i .== line.to))
Y_tf = Y[t_idx,f_idx]
Y_ft = Y[f_idx,t_idx]
Vm_f = Vm[f_idx]; Va_f = Va[f_idx]
Vm_t = Vm[t_idx]; Va_t = Va[t_idx]
# Yabs2 = max(abs2(Y_tf), abs2(Y_ft))
if options[:lossless] == true
  Yabs2 = abs2(1.0 / line.x)
else
  Yabs2 = abs2(line.r / (line.r^2 + line.x^2) - im * (line.x / (line.r^2 + line.x^2)))
end
if options[:remove_tap] == false
  t   = (line.ratio == 0.0 ? 1.0 : line.ratio) * exp(im * line.angle)
  a   = real(t)
  b   = imag(t)
  Tik = abs(t)
  φik = angle(t)
else
  Tik = 1.0
  φik = 0.0
  a   = 1.0
  b   = 0.0
end
## NOTE: current from Frank & Rebennack OPF primer eq 4.6; turns/tap ratios ARE accounted for; eq 5.11 + Remark 5.1 looks wrong
F_l = @NLexpression(opfmodel, current2, (Vm_f^2 + (a^2 + b^2) * Vm_t^2 - 2 * Vm_f * Vm_t * ( a * cos(Va_f - Va_t) + b * sin(Va_f - Va_t) ))*(Yabs2/(a^2 + b^2)^2) - flowmax)