class InclusionCheck < ApplicationRecord
  SECCION_REVISION   = 12
  SECCION_PLATAFORMA = 10
  NOMBRE_SECCION     = '. INCLUSIÓN Y ACCESIBILIDAD UNIVERSAL (informativo)'

  CRITERIOS = [
    { numero: 1,
      elemento: 'Ruta accesible y área de aproximación',
      criterio: 'Ascensor conectado a la ruta accesible, cuando corresponda. Área frente al ascensor mínimo 1,50 × 1,50 m y ancho frente a puerta no menor que la profundidad de la cabina.' },
    { numero: 2,
      elemento: 'Panel de comando: ubicación',
      criterio: 'Botones/sistemas de activación entre 0,90 y 1,20 m de altura y a mínimo 0,40 m del vértice interior de la cabina.' },
    { numero: 3,
      elemento: 'Botones de comando',
      criterio: 'Botones de numeración con diámetro mínimo 2 cm, en sobrerrelieve, con contraste de color y numeración Braille alineada lateralmente.' },
    { numero: 4,
      elemento: 'Pasamano',
      criterio: 'Pasamano en al menos una pared lateral, en todo su largo cuando corresponda; diámetro 3,5–5 cm, separación de la pared ≥ 3,5 cm y altura 0,90 m.' },
    { numero: 5,
      elemento: 'Pasamano en cabinas > 2 m',
      criterio: 'Cuando el ancho de cabina sea superior a 2 m, pasamano instalado en al menos dos paredes.' },
    { numero: 6,
      elemento: 'Espejo o dispositivo de retrovisión',
      criterio: 'Cuando por las dimensiones de la cabina una persona en silla de ruedas no pueda girar, debe existir espejo u otro dispositivo que permita observar obstáculos al retroceder. Si es espejo: inastillable e instalado desde 0,30 m de altura.' },
    { numero: 7,
      elemento: 'Señal audible y tiempo de detención',
      criterio: 'Señal audible indicando el número de piso en cada parada y tiempo de detención suficiente para permitir el paso de personas en silla de ruedas, con discapacidad visual o movilidad reducida.' }
  ].freeze

  belongs_to :revision, polymorphic: true
  has_many_attached :photos

  validates :numero, presence: true, uniqueness: { scope: [:revision_type, :revision_id] }
  validate :no_implementado_y_na_excluyentes

  def estado
    return "No implementado" if no_implementado
    return "N/A" if na
    "Cumple"
  end

  private

  def no_implementado_y_na_excluyentes
    errors.add(:base, "No puede estar marcado como No implementado y N/A a la vez") if no_implementado && na
  end
end
