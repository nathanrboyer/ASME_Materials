# Mandatory Appendix 1: Nomenclature
#=
A_1 = curve fitting constant for the elastic region of the stress-strain curve (KM-620)
A_2 = curve fitting constant for the plastic region of the stress-strain curve (KM-620)
E_y = modulus of elasticity evaluated at the temperature of interest, see ASME Section II Part D
El = minimum specified elongation, %
H = <undefined>
K = <undefined>
m_1 = <undefined>
m_2 = <undefined>
R = Sy/Su
RA = minimum specified reduction of area, %
γ_1 = true strain in the micro-strain region of the stress-strain curve (KM-620)
γ_2 = true strain in the macro-strain region of the stress-strain curve (KM-620)
ϵ_p = stress-strain curve fitting parameter (KM-620)
ϵ_ts = true total strain (KM-620)
ϵ_ys = 0.2% engineering offset strain (KM-620)
ϵ_1 = true plastic strain in the micro-strain region of the stress-strain curve (KM-620)
ϵ_2 = true plastic strain in the macro-strain region of the stress-strain curve (KM-620)
σ_t = true stress at which the true strain will be evaluated (KM-620)
σ_uts = engineering ultimate tensile stress evaluated at the temperature of interest (KM-620)
σ_ys = engineering yield stress evaluated at the temperature of interest (KM-620)
σ_utst = true ultimate tensile stress evaluated at the true ultimate tensile strain
=#

# Section KM-620
ϵ_ts(σ_t, E_y, γ_1, γ_2) = @. σ_t / E_y + γ_1 + γ_2 # KM-620.1
γ_1(ϵ_1, H) = @. ϵ_1 / 2 * (1 - tanh(H)) # KM-620.2
γ_2(ϵ_2, H) = @. ϵ_2 / 2 * (1 + tanh(H)) # KM-620.3
ϵ_1(σ_t, A_1, m_1) = @. (σ_t / A_1)^(1 / m_1) # KM-620.4
A_1(σ_ys, ϵ_ys, m_1) = σ_ys * (1 + ϵ_ys) / (log(1 + ϵ_ys))^m_1 # KM-620.5
m_1(R, ϵ_p, ϵ_ys) = (log(R) + (ϵ_p - ϵ_ys)) / log(log(1+ϵ_p)/log(1+ϵ_ys)) # KM-620.6
ϵ_2(σ_t, A_2, m_2) = @. (σ_t / A_2)^(1 / m_2) # KM-620.7
A_2(σ_uts, m_2) = (σ_uts * exp(m_2)) / (m_2 ^ m_2) # KM-620.8
H(σ_t, σ_ys, σ_uts, K) = @. 2 * (σ_t - (σ_ys + K * (σ_uts - σ_ys))) / (K * (σ_uts - σ_ys)) # KM-620.9
R(σ_ys, σ_uts) = σ_ys / σ_uts # KM-620.10
ϵ_ys() = 0.002 # KM-620.11
K(R) = 1.5*R^1.5 - 0.5*R^2.5 - R^3.5 # KM-620.12
σ_utst(σ_uts, m_2) = σ_uts * exp(m_2) # KM-620.13

# Table KM-620 (NOTE: Ferritic steel includes carbon, low alloy, and alloy steels, and ferritic, martensitic, and iron-based age-hardening stainless steels.)
const tableKM620 = DataFrame("Material" => ["Ferritic steel",
                                        "Austenitic stainless steel and nickel-based alloys",
                                        "Duplex stainless steel",
                                        "Precipitation hardening, nickel based",
                                        "Aluminum",
                                        "Copper",
                                        "Titanium and zirconium"],
                                "Maximum Temperature (°F)" => [900,
                                                        900,
                                                        900,
                                                        1000,
                                                        250,
                                                        150,
                                                        500],
                                "m₂" => [R -> 0.60 * (1.00 - R),
                                        R -> 0.75 * (1.00 - R),
                                        R -> 0.70 * (0.95 - R),
                                        R -> 1.09 * (0.93 - R),
                                        R -> 0.52 * (0.98 - R),
                                        R -> 0.50 * (1.00 - R),
                                        R -> 0.50 * (0.98 - R)],
                                "m₃" => [(El) -> 2*log(1+(El/100)),
                                        (El) -> 3*log(1+(El/100)),
                                        (El) -> 2*log(1+(El/100)),
                                        (El) -> 1*log(1+(El/100)),
                                        (El) -> 1.3*log(1+(El/100)),
                                        (El) -> 2*log(1+(El/100)),
                                        (El) -> 1.3*log(1+(El/100))],
                                "m₄" => (RA) -> log(100 / (100 - RA)),
                                "m₅" => [2.2,
                                        0.6,
                                        2.2,
                                        2.2,
                                        2.2,
                                        2.2,
                                        2.2],
                                "ϵₚ" => [2.0E-5,
                                        2.0E-5,
                                        2.0E-5,
                                        2.0E-5,
                                        5.0E-6,
                                        5.0E-6,
                                        2.0E-5]
                                )
