class BlackInspectionBuilder
  ASCENSOR_SECTIONS    = (0..11).to_a
  ESCALA_SECTIONS      = [0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15]
  PLATAFORMA_SECTIONS  = (0..9).to_a
  SALVAESCALA_SECTIONS = (0..7).to_a

  def self.revision_class_for(type_of)
    case type_of
    when "escala"   then LadderRevision
    when "ascensor" then Revision
    when "plat"     then PlatRevision
    end
  end

  def self.find(inspection)
    Inspection.find_by(number: -inspection.number, item_id: inspection.item_id, state: "black", result: "black")
  end

  def self.find_revision(inspection)
    black = find(inspection)
    klass = revision_class_for(inspection.item.group.type_of)
    black && klass&.find_by(inspection_id: black.id)
  end

  def self.find_or_create!(inspection)
    new(inspection).find_or_create!
  end

  def self.replace_defects!(black_revision, source_revision, type_of)
    if type_of == "plat"
      black_revision.plat_revision_rules_plats.destroy_all
      source_revision.plat_revision_rules_plats.each do |src|
        black_revision.plat_revision_rules_plats.create!(rules_plat_id: src.rules_plat_id, level: "L")
      end
    else
      src_by_section = source_revision.revision_colors.index_by(&:section)
      dst_by_section = black_revision.revision_colors.index_by(&:section)

      (src_by_section.keys | dst_by_section.keys).compact.each do |section|
        src    = src_by_section[section]
        codes  = Array(src&.codes)
        points = Array(src&.points)
        attrs  = { color: false, codes: codes, points: points, levels: Array.new(codes.size, "L") }

        if (dst = dst_by_section[section])
          dst.update!(attrs)
        elsif codes.any?
          black_revision.revision_colors.create!(attrs.merge(section: section))
        end
      end
    end
  end

  def initialize(inspection)
    @inspection     = inspection
    @item           = inspection.item
    @type_of        = @item.group.type_of
    @revision_class = self.class.revision_class_for(@type_of)
  end

  def find_or_create!
    black    = self.class.find(@inspection) || create_inspection!
    revision = @revision_class&.find_by(inspection_id: black.id) || create_revision!(black)
    [black, revision]
  end

  private

  def create_inspection!
    factura = Facturacion.find_by(number: 0)

    black = Inspection.create!(
      number: -@inspection.number,
      item_id: @item.id,
      principal_id: @item.principal_id,
      place: @inspection.place,
      ins_date: @inspection.ins_date,
      state: "black",
      result: "black",
      rerun: false,
      facturacion_id: factura.id,
      region: "no",
      comuna: "no"
    )

    @inspection.users.each { |user| black.users << user }

    black.created_at = Time.current - 1.minute
    black.save
    @inspection.created_at = Time.current
    @inspection.save

    black
  end

  def create_revision!(black)
    return nil unless @revision_class

    attrs = { inspection_id: black.id, item_id: @item.id }
    attrs[:group_id] = @item.group_id unless @type_of == "escala"

    revision = @revision_class.create!(attrs)
    revision.created_at = Time.current - 1.minute
    revision.save

    current_revision = @revision_class.find_by(inspection_id: @inspection.id)
    if current_revision
      current_revision.created_at = Time.current
      current_revision.save
    end

    case @type_of
    when "escala"
      ESCALA_SECTIONS.each { |s| revision.revision_colors.create!(section: s, color: false) }
    when "ascensor"
      ASCENSOR_SECTIONS.each { |s| revision.revision_colors.create!(section: s, color: false) }
    when "plat"
      sections =
        case @item.group.secondary_type
        when "plataforma"  then PLATAFORMA_SECTIONS
        when "salvaescala" then SALVAESCALA_SECTIONS
        else []
        end
      sections.each { |s| revision.plat_revision_sections.create!(section: s, color: false) }
    end

    revision
  end
end